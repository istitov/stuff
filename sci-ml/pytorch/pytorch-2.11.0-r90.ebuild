# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
inherit distutils-r1 prefix

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
# of them as an extra. Restored as a frozen rollback for the vllm(torch==2.11)
# stack (2.13.0-r91 forward otherwise). One deliberate deviation from torch
# 2.11.0's Requires-Dist: it caps setuptools<82, but that cap is unsatisfiable
# here -- it forces setuptools-79, which collides with any installed consumer
# needing >=80 (e.g. dev-python/ipython) since no setuptools exists in [80,82).
# The identical 2.13.0-r91 frontend runs on setuptools 83, and the cap only
# guards torch's cpp_extension, so relax to the same >=77.0.3 floor (no upper
# cap). verified 2026-08-08 against torch-2.11.0
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
DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.9.0-dontbuildagain.patch
	"${FILESDIR}"/${PN}-2.10.0-cpp-extension-multilib.patch
)

src_prepare() {
	# Replace placeholders added by cpp-extension.patch
	sed -e "s|%LIB_DIR%|$(get_libdir)|g" \
		-i torch/utils/cpp_extension.py || die

	# Set build dir for pytorch's setup
	sed -e "/BUILD_DIR/s|build|/var/lib/caffe2/|" \
		-i tools/setup_helpers/env.py || die

	# Drop legacy from pyproject.toml
	sed -e "/build-backend/s|:__legacy__||" \
		-i pyproject.toml || die

	distutils-r1_src_prepare

	hprefixify tools/setup_helpers/env.py
}

python_compile() {
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	USE_SYSTEM_LIBS=ON \
	CMAKE_BUILD_DIR="${BUILD_DIR}" \
	distutils-r1_python_compile develop sdist
}

python_install() {
	USE_SYSTEM_LIBS=ON distutils-r1_python_install
}
