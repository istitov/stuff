# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 2.14.0 moved the build from setuptools to scikit-build-core: setup.py is now
# a deprecation shim that only forwards `install`/`develop` to pip, and
# tools/setup_helpers/env.py is gone. Both halves of the old split went with
# them -- files/pytorch-2.9.0-dontbuildagain.patch deleted setup.py's
# build_pytorch() call, and the BUILD_DIR sed pointed env.py at the
# CMakeCache.txt sci-ml/caffe2 installs to /var/lib/caffe2, which made setup.py
# believe the build already existed and skip it.
#
# The split is preserved anyway, via wheel.cmake (see src_prepare): with it
# false, scikit-build-core runs no CMake at all and packages only the python
# trees named in upstream's own [tool.scikit-build.wheel] packages list
# (torch, torchgen, functorch). That is exactly this package's half of the
# split -- sci-ml/caffe2 keeps building the C++ and owns both torch/_C and the
# generated torch/version.py, neither of which exists in the source tree, so
# there is nothing to collide over. Without it scikit-build-core would rebuild
# all of libtorch a second time.
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
inherit distutils-r1

DESCRIPTION="Tensors and Dynamic neural networks in Python"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/pytorch/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="test"

REQUIRED_USE=${PYTHON_REQUIRED_USE}
# The block below mirrors torch's unconditional Requires-Dist verbatim, floors
# included, so it can be diffed against the built
# torch-${PV}.dist-info/METADATA. Only typing-extensions is imported by
# `import torch`; the rest are reached lazily -- sympy and networkx from
# torch.fx, jinja2 and filelock from the inductor codegen and its compile
# cache, fsspec from torch.load/save on remote paths, setuptools from
# torch.utils.cpp_extension. Lazy does not mean optional: upstream marks none
# of them as an extra. verified 2026-07-27
RDEPEND="
	${PYTHON_DEPS}
	~sci-ml/caffe2-${PV}[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/fsspec-0.8.5[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		>=dev-python/networkx-2.5.1[${PYTHON_USEDEP}]
		>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
		>=dev-python/sympy-1.13.3[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
	')
"
# Upstream's [build-system] requires list, minus cmake and ninja: those are
# listed only for the CMake half of the build, which wheel.cmake=false turns
# off, and scikit-build-core drops them from its own requires in the same case
# (build/__init__.py gates them on settings.wheel.cmake).
DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		>=dev-python/scikit-build-core-1.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}"/${P}-cpp-extension-multilib.patch
)

src_prepare() {
	# Do not let scikit-build-core run CMake. sci-ml/caffe2 has already built
	# and installed the C++ side; without this the PEP 517 build would compile
	# all of libtorch again into a second copy. wheel.cmake=false makes
	# scikit-build-core skip the CMake configure/build/install entirely
	# (build/wheel.py) and package just the python trees from
	# [tool.scikit-build.wheel] packages.
	#
	# wheel.platlib is forced true alongside it: scikit-build-core targets
	# purelib instead of platlib when cmake is off
	# (common_wheel_helpers.py), and this package must stay in the platlib
	# that sci-ml/caffe2 installs torch/_C and torch/version.py into.
	sed -e '/^\[tool\.scikit-build\.wheel\]/a cmake = false\nplatlib = true' \
		-i pyproject.toml || die
	grep -q '^cmake = false' pyproject.toml \
		|| die "wheel.cmake=false was not inserted -- upstream moved the table"

	# project.license-files globs third_party/**/LICENSE{,.txt,.rst}, and PEP
	# 639 requires every pattern to match at least one file -- pyproject_metadata
	# hard-errors otherwise ("Every pattern in project.license-files must match
	# at least one file"). The GitHub archive carries no submodule contents, so
	# all three third_party globs are empty and the metadata build dies before
	# it starts. Drop them: we unbundle third_party against system libraries,
	# so none of those licences cover anything this package installs. The
	# top-level LICENSE, which does, is kept.
	sed -i -e '/^\s*"third_party\/\*\*\/LICENSE/d' pyproject.toml || die
	grep -q '"LICENSE",' pyproject.toml \
		|| die "top-level LICENSE entry disappeared from license-files"

	distutils-r1_src_prepare

	# Replace the placeholder introduced by cpp-extension-multilib.patch.
	# MUST run after distutils-r1_src_prepare, which is what applies PATCHES:
	# the placeholder does not exist upstream, so running the sed first
	# matches nothing, exits 0 and ships the literal. See 2.13.0-r92.
	sed -e "s|%LIB_DIR%|$(get_libdir)|g" \
		-i torch/utils/cpp_extension.py || die
	if grep -q '%LIB_DIR%' torch/utils/cpp_extension.py; then
		die "%LIB_DIR% placeholder survived substitution"
	fi
}

python_compile() {
	# PYTORCH_BUILD_VERSION feeds upstream's dynamic-metadata provider
	# (tools/metadata/version.py), which resolves the wheel version from it
	# rather than from git.
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	distutils-r1_python_compile
}
