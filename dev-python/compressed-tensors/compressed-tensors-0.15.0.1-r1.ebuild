# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 optfeature pypi

DESCRIPTION="Library for compressed safetensors of neural network models"
HOMEPAGE="
	https://github.com/vllm-project/compressed-tensors
	https://pypi.org/project/compressed-tensors/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Declare direct imports omitted upstream. verified 2026-08-04
RDEPEND="
	sci-ml/huggingface_hub[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-1.7.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.45.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/loguru[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
		sci-ml/safetensors[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	')
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

# Pin the VCS-derived sdist version. Accept setuptools-scm >=8 because the used
# formatting API remains stable across 8-10.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

# Run only offline, accelerator-independent tests.
python_test() {
	local -x HF_HUB_OFFLINE=1
	local -x TRANSFORMERS_OFFLINE=1
	local -a test_paths=(
		tests/test_compressors/test_fp4_quant.py
		tests/test_compressors/test_fp8_quant.py
		tests/test_compressors/test_int_quant.py
		tests/test_compressors/test_mxfp4_quant.py
		tests/test_compressors/test_mxfp8_quant.py
		tests/test_compressors/test_pack_quant.py
		tests/test_compressors/test_packed_asym_decompression.py
		tests/test_configs
		tests/test_quantization/test_configs
		tests/test_quantization/test_quant_args.py
		tests/test_quantization/test_quant_config.py
		tests/test_quantization/test_quant_metadata.py
		tests/test_quantization/test_quant_scheme.py
		tests/test_quantization/test_utils
		tests/test_transform/test_transform_args.py
		tests/test_transform/test_transform_config.py
		tests/test_transform/test_transform_scheme.py
		tests/test_utils/test_helpers.py
		tests/test_utils/test_safetensors_load.py
		tests/test_utils/test_type.py
	)

	epytest "${test_paths[@]}"
}

pkg_postinst() {
	optfeature "integration with Accelerate offloading" sci-ml/accelerate
}
