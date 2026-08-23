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

LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

# transformers is capped <5 upstream: v5 breaks tokenizer loading for several
# models (TokenizerInfo.from_huggingface), so the pyproject pins >=4.38.0,<5.
#
# gcc:15 is a runtime dep because the CUDA token-bitmask kernel is
# JIT-compiled at import via torch.utils.cpp_extension, and nvcc rejects a
# host gcc newer than the toolkit supports (CUDA 13 tops out at gcc 15).
# The slot here MUST track the /usr/bin/gcc-15 and /usr/bin/g++-15 fallback
# in ${PN}-0.2.2-cuda-host-compiler.patch: when a CUDA bump raises this
# slot, update that patch's fallback in the same commit. cuda_gccdir cannot
# resolve it -- it runs on the user's machine at JIT time, not at build.
RDEPEND="
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		sys-devel/gcc:15
	)
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/transformers-5
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
		virtual/triton[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	>=dev-build/cmake-3.18
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
		>=dev-python/scikit-build-core-0.10[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/${PN}-respect-toolchain-flags.patch"
	"${FILESDIR}/${PN}-0.2.3-load-binding-from-package.patch"
	"${FILESDIR}/${PN}-0.2.5-align-tests-with-implementation.patch"
	"${FILESDIR}/${PN}-0.2.2-cuda-host-compiler.patch"
)

src_unpack() {
	default
	# GitHub's archive omits submodule contents; drop the empty 3rdparty/dlpack
	# placeholder and stage the pinned dlpack commit where the include path and
	# the header-install rule expect it.
	rmdir "${S}/3rdparty/dlpack" || die
	mv "${WORKDIR}/dlpack-${DLPACK_COMMIT}" "${S}/3rdparty/dlpack" || die
}

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_configure() {
	local device
	# tvm_ffi imports PyTorch, which probes available accelerator devices.
	for device in /dev/kfd /dev/dri/render* /dev/accel/accel*; do
		[[ -e ${device} ]] && addpredict "${device}"
	done

	distutils-r1_src_configure
}

python_test() {
	# The excluded tests download gated or multi-gigabyte model tokenizers.
	epytest -m "not hf_token_required"
}
