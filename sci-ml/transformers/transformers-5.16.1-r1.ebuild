# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="State-of-the-art Machine Learning for JAX, PyTorch and TensorFlow"
HOMEPAGE="
	https://pypi.org/project/transformers/
	https://huggingface.co/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test torch"

RDEPEND="
	>=sci-ml/huggingface_hub-1.5.0[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/huggingface_hub-2
	>=sci-ml/tokenizers-0.23.1[${PYTHON_SINGLE_USEDEP}]
	<sci-ml/tokenizers-0.24
	$(python_gen_cond_dep '
		dev-python/filelock[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.17[${PYTHON_USEDEP}]
		>=dev-python/packaging-20.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-5.1[${PYTHON_USEDEP}]
		>=dev-python/regex-2025.10.22[${PYTHON_USEDEP}]
		>=dev-python/tqdm-4.60[${PYTHON_USEDEP}]
		dev-python/typer[${PYTHON_USEDEP}]
		>=sci-ml/safetensors-0.8.0[${PYTHON_USEDEP}]
	')
	torch? (
		>=sci-ml/accelerate-1.1.0[${PYTHON_SINGLE_USEDEP}]
		sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
		>=sci-ml/pytorch-2.5[${PYTHON_SINGLE_USEDEP}]
	)
"
# The model tests load with device_map, which needs accelerate even when
# USE=torch is off. verified 2026-09-16
BDEPEND="test? (
	$(python_gen_cond_dep '
		>=dev-python/parameterized-0.9[${PYTHON_USEDEP}]
	')
	>=sci-ml/accelerate-1.1.0[${PYTHON_SINGLE_USEDEP}]
	sci-ml/datasets[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[distributed]
)"

EPYTEST_PLUGINS=( pytest-xdist )
distutils_enable_tests pytest

python_test() {
	local compile_test="tests/models/gpt2/test_modeling_gpt2.py::GPT2ModelTest::test_generate_compilation_all_outputs"
	local EPYTEST_DESELECT=(
		# Optional dev-python/blobfile is not packaged.
		tests/models/gpt2/test_tokenization_gpt2.py::GPT2TokenizationTest::test_tokenization_tiktoken
		# Running this torch.compile test beside other workers aborts in libtorch.
		"${compile_test}"
	)
	local EPYTEST_IGNORE=()
	# Each tokenization module downloads its reference tokenizer from
	# huggingface.co during class setup, so none of its tests can run
	# behind the network sandbox. With it off they pass, so drop them
	# only when it is on. verified 2026-09-16
	if has network-sandbox ${FEATURES}; then
		EPYTEST_IGNORE+=(
			tests/models/bert/test_tokenization_bert.py
			tests/models/distilbert/test_tokenization_distilbert.py
			tests/models/gpt2/test_tokenization_gpt2.py
			tests/models/roberta/test_tokenization_roberta.py
		)
	fi
	epytest -n auto --maxprocesses=8 --dist loadfile \
		tests/models/bert \
		tests/models/gpt2 \
		tests/models/roberta \
		tests/models/distilbert

	EPYTEST_DESELECT=(
		tests/models/gpt2/test_tokenization_gpt2.py::GPT2TokenizationTest::test_tokenization_tiktoken
	)
	epytest "${compile_test}"
}
