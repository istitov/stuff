# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

# GitHub archives omit required dlpack headers, so fetch the tag's submodule
# commit separately and recheck it on bumps. googletest/cpptrace stay disabled;
# picojson is included in the archive. # verified 2026-07-24
DLPACK_COMMIT="bbd2f4d32427e548797929af08cfe2a9cbb3cf12"

DESCRIPTION="Efficient, flexible structured generation engine for LLMs"
HOMEPAGE="
	https://xgrammar.mlc.ai/
	https://github.com/mlc-ai/xgrammar
	https://pypi.org/project/xgrammar/
"
# PyPI has shipped only wheels since 0.2.4. # verified 2026-07-24
SRC_URI="
	https://github.com/mlc-ai/xgrammar/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/dmlc/dlpack/archive/${DLPACK_COMMIT}.tar.gz
		-> ${PN}-dlpack-${DLPACK_COMMIT}.tar.gz
"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="cuda"

# transformers is capped <5 upstream: v5 breaks tokenizer loading for several
# models (TokenizerInfo.from_huggingface), so the pyproject pins >=4.38.0,<5.
#
# CUDA kernels JIT through PyTorch, so gcc:15 is a runtime dependency; CUDA 13
# rejects newer hosts. Keep its slot synchronized with the compiler fallback in
# ${PN}-0.2.2-cuda-host-compiler.patch; cuda_gccdir cannot run at JIT time.
#
# Gate virtual/triton like upstream's x86_64 marker, not by USE=cuda: ROCm
# tensors also report device.type="cuda" and select Triton. The virtual covers
# both backends and is unavailable on arm64. # verified 2026-09-09
RDEPEND="
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		sys-devel/gcc:15
	)
	amd64? (
		$(python_gen_cond_dep '
			virtual/triton[${PYTHON_USEDEP}]
		')
	)
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/transformers-5
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
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
	# Replace the empty submodule placeholder with the pinned dlpack tree.
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
