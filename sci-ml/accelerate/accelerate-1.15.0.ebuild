# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="Run your *raw* PyTorch training script on any kind of device"
HOMEPAGE="https://github.com/huggingface/accelerate"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=sci-ml/huggingface_hub-0.21.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-2.0.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
		>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		>=sci-ml/safetensors-0.4.3[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}"
# gloo lives on caffe2, requires caffe2[distributed], and is profile-masked
# outside amd64. Verified 2026-09-10.
BDEPEND="test? (
	$(python_gen_cond_dep '
		dev-python/networkx[${PYTHON_USEDEP}]
		dev-python/parameterized[${PYTHON_USEDEP}]
	')
	>=sci-ml/pytorch-2.13.0
	amd64? ( >=sci-ml/caffe2-2.13.0[gloo] )
	sci-ml/evaluate[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchdata[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchvision[${PYTHON_SINGLE_USEDEP}]
	sci-ml/transformers[${PYTHON_SINGLE_USEDEP}]
)"

EPYTEST_PLUGINS=( pytest-order pytest-xdist )
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		tests/fsdp/test_fsdp.py::FSDPPluginIntegration::test_auto_wrap_policy
		tests/fsdp/test_fsdp.py::FSDPPluginIntegration::test_ignored_modules_regex
		tests/fsdp/test_fsdp.py::FSDP2PluginIntegration::test_auto_wrap_policy
		tests/fsdp/test_fsdp.py::FSDP2PluginIntegration::test_ignored_modules_regex
		tests/test_accelerator.py::AcceleratorTester::test_env_var_device
		tests/test_cli.py::AccelerateLauncherTester::test_config_compatibility
		tests/test_cli.py::ModelEstimatorTester
		tests/test_cpu.py::MultiCPUTester::test_cpu
		tests/test_examples.py::FeatureExamplesTests
		tests/test_modeling_utils.py::ModelingUtilsTester::test_get_balanced_memory_no_split_module_classes_set
		tests/test_modeling_utils.py::ModelingUtilsTester::test_infer_auto_device_map_on_t0pp
		tests/test_tracking.py::ClearMLTest
		tests/test_utils.py::UtilsTester::test_patch_environment_key_exists
	)

	local -x CUDA_VISIBLE_DEVICES=""
	epytest tests
}
