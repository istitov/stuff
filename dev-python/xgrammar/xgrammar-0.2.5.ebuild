# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

# dlpack is a git submodule (3rdparty/dlpack); its headers sit on
# XGRAMMAR_INCLUDE_PATH and are installed by the top-level CMakeLists, so it is
# required at build time. GitHub's archive tarball omits submodule contents, so
# stage the pinned commit separately (git ls-tree v${PV} -- 3rdparty/dlpack).
# The other two submodules stay unbuilt with our options: googletest only under
# XGRAMMAR_BUILD_CXX_TESTS (default OFF) and cpptrace under XGRAMMAR_ENABLE_CPPTRACE
# (default OFF, scikit-build passes no cmake.args); picojson is vendored in-tree
# and ships in the archive. Re-check the commit on every bump. # verified 2026-07-24
DLPACK_COMMIT="bbd2f4d32427e548797929af08cfe2a9cbb3cf12"

DESCRIPTION="Efficient, flexible structured generation engine for LLMs"
HOMEPAGE="
	https://xgrammar.mlc.ai/
	https://github.com/mlc-ai/xgrammar
	https://pypi.org/project/xgrammar/
"
# PyPI stopped shipping sdists at 0.2.4 (wheels only), so build from the GitHub
# release tag rather than pypi_sdist_url. # verified 2026-07-24
SRC_URI="
	https://github.com/mlc-ai/xgrammar/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/dmlc/dlpack/archive/${DLPACK_COMMIT}.tar.gz
		-> ${PN}-dlpack-${DLPACK_COMMIT}.tar.gz
"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# vllm 0.21.0 pins xgrammar <1.0.0; 0.2.x fits.
# transformers is capped <5 upstream: v5 breaks tokenizer loading for several
# models (TokenizerInfo.from_huggingface), so the pyproject pins >=4.38.0,<5.
# Upstream also lists `triton` as a runtime dep on Linux x86_64, but triton
# isn't packaged in ::gentoo or here yet -- vllm + xgrammar's grammar-matching
# paths we exercise don't require it. # verified 2026-07-24
RDEPEND="
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/transformers-5
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.9[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	')
"
# apache-tvm-ffi is also a build dep: cpp/tvm_ffi/CMakeLists.txt runs
# find_package(tvm_ffi) at configure time, which imports the tvm_ffi module
# and reads its share/cmake/tvm_ffi config. # verified 2026-07-24
BDEPEND="
	>=dev-build/cmake-3.18
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.9[${PYTHON_USEDEP}]
		>=dev-python/nanobind-2.5.0[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	default
	# GitHub's archive omits submodule contents; drop the empty 3rdparty/dlpack
	# placeholder and stage the pinned dlpack commit where the include path and
	# the header-install rule expect it.
	rm -rf "${S}/3rdparty/dlpack" || die
	mv "${WORKDIR}/dlpack-${DLPACK_COMMIT}" "${S}/3rdparty/dlpack" || die
}

python_compile() {
	# xgrammar imports tvm_ffi during the build (cmake find_package and stub
	# generation), and tvm_ffi opens accelerator device nodes at import.
	# Without these the sandbox denies /dev/kfd and /dev/accel/accel0 and
	# the build aborts. Predict them so the import proceeds. # verified 2026-06-12
	addpredict /dev/kfd
	addpredict /dev/accel
	distutils-r1_python_compile
}

python_install_all() {
	distutils-r1_python_install_all

	# FIXME: workaround, not proper fix.
	# xgrammar/load_binding.py calls tvm_ffi's load_lib_module without
	# passing extra_lib_paths, so tvm_ffi searches only its own lib/
	# dirs and a few PATH entries. The .so installed at xgrammar/
	# libxgrammar_bindings.so is invisible to that search. Symlink it
	# into tvm_ffi's lib/ so the lookup succeeds. Upstream wheel works
	# only by accident (their wheel layout differs from a normal
	# site-packages install). # verified 2026-05-16 against 0.2.0:
	# without this symlink, `from vllm import LLM` dies during
	# xgrammar module init.
	#
	# Upstream-able fix: patch xgrammar/load_binding.py to pass
	# `extra_lib_paths=[Path(__file__).parent]` to load_lib_module --
	# self-contained inside xgrammar's package boundary, no
	# cross-package symlink dance. Switch to that pattern (and ship
	# the patch in files/) when there's appetite for a maintained
	# patch rather than this dosym workaround.  Also remove the
	# symlink risk: a hypothetical future apache-tvm-ffi shipping its
	# own libxgrammar_bindings.so would collide here.
	local sp
	sp=$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))') || die
	local tvm_lib="${ED}${sp}/tvm_ffi/lib"
	dodir "${tvm_lib#${ED}}"
	dosym "${sp}/xgrammar/libxgrammar_bindings.so" "${tvm_lib#${ED}}/libxgrammar_bindings.so"
}
