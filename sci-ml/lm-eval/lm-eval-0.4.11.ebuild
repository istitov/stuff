# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

# upstream PyPI dist filename uses underscore (lm_eval-x.y.z.tar.gz),
# project page is /pypi/lm-eval/
PYPI_PN="lm_eval"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="A framework for evaluating language models (lm-evaluation-harness)"
HOMEPAGE="
	https://github.com/EleutherAI/lm-evaluation-harness
	https://pypi.org/project/lm-eval/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="api sentencepiece statsmodels vllm"

# Core deps from pyproject.toml [project.dependencies] at v0.4.11.
# Optional [project.optional-dependencies] groups are wired as USE flags
# only where every dep is reachable in our overlay set:
#  api          -> aiohttp, requests, tenacity, tqdm, tiktoken
#  sentencepiece-> sentencepiece
#  statsmodels  -> upstream "discrim_eval" extra (statsmodels)
#  vllm         -> vllm
# Other extras (hf, math, ifeval, multilingual, ruler, wandb, japanese,
# longbench, libra, ipex, gptq, gptqmodel, optimum, sparsify, audiolm_qwen,
# unitxt, zeno, ibm_watsonx_ai, acpbench) gate on packages we do not
# currently carry; users wanting them must `pip install lm_eval[<extra>]`.
#
# single-impl: sci-ml/{datasets,evaluate} are SINGLE_IMPL; rest of stack is
# multi-impl, wrapped via python_gen_cond_dep.
RDEPEND="
	>=sci-ml/datasets-2.16.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/evaluate-0.4.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/dill[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/jsonlines[${PYTHON_USEDEP}]
		dev-python/more-itertools[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pytablewriter[${PYTHON_USEDEP}]
		dev-python/rouge-score[${PYTHON_USEDEP}]
		dev-python/sacrebleu[${PYTHON_USEDEP}]
		dev-python/sqlitedict[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/word2number[${PYTHON_USEDEP}]
		dev-python/zstandard[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		api? (
			dev-python/aiohttp[${PYTHON_USEDEP}]
			dev-python/requests[${PYTHON_USEDEP}]
			dev-python/tenacity[${PYTHON_USEDEP}]
			dev-python/tiktoken[${PYTHON_USEDEP}]
			dev-python/tqdm[${PYTHON_USEDEP}]
		)
		sentencepiece? ( >=sci-ml/sentencepiece-0.1.98[${PYTHON_USEDEP}] )
		statsmodels? ( dev-python/statsmodels[${PYTHON_USEDEP}] )
		vllm? ( >=dev-python/vllm-0.4.2[${PYTHON_USEDEP}] )
	')
"
