# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Efficient, flexible structured generation engine for LLMs"
HOMEPAGE="
	https://xgrammar.mlc.ai/
	https://github.com/mlc-ai/xgrammar
	https://pypi.org/project/xgrammar/
"

LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

# The packaged-library lookup patch uses load_lib_module(extra_lib_paths=...),
# which apache-tvm-ffi added in 0.1.11.
RDEPEND="
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
		sys-devel/gcc:15
	)
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
		dev-python/triton-bin[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	>=dev-build/cmake-3.18
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.11[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/${PN}-respect-toolchain-flags.patch"
	"${FILESDIR}/${PN}-0.2.3-load-binding-from-package.patch"
	"${FILESDIR}/${PN}-0.2.2-cuda-host-compiler.patch"
)

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
