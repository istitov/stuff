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
IUSE="+api ifeval math sentencepiece statsmodels vllm"

# Core deps from pyproject.toml [project.dependencies] at v0.4.11.
# Optional [project.optional-dependencies] groups are wired as USE flags
# only where every dep is reachable in our overlay set:
#  api          -> aiohttp, requests, tenacity, tqdm, tiktoken
#  ifeval       -> langdetect, immutabledict, nltk>=3.9.1
#  math         -> sympy, antlr4-python3-runtime==4.11.*, math-verify
#  sentencepiece-> sentencepiece
#  statsmodels  -> upstream "discrim_eval" extra (statsmodels)
#  vllm         -> vllm
# Other extras (hf, multilingual, ruler, wandb, japanese, longbench,
# libra, ipex, gptq, gptqmodel, optimum, sparsify, audiolm_qwen,
# unitxt, zeno, ibm_watsonx_ai, acpbench) gate on packages we do not
# currently carry; users wanting them must `pip install lm_eval[<extra>]`.
#
# math: at lm_eval 0.4.11, lm_eval/tasks/minerva_math/utils.py asserts
#   version("antlr4-python3-runtime").startswith("4.11")
# at task-load, so the antlr4-4.11* pin is load-bearing, not advisory
# (verified upstream 2026-05-11). We carry the older
# antlr4-python3-runtime-4.11.0 alongside ::gentoo's 4.13.2 for this;
# flipping USE=math triggers the downgrade.
#
# ifeval: at lm_eval 0.4.11, lm_eval/tasks/leaderboard/ifeval/
# instructions_util.py asserts nltk>=3.9.1 at module import (older
# nltk has a remote-code-exec via `punkt`, see EleutherAI/lm-
# evaluation-harness#2210 and nltk/nltk#3266), so the >=nltk-3.9.1
# bound is load-bearing, not advisory (verified upstream 2026-05-11).
# The task also auto-downloads the punkt_tab tokenizer at the same
# import — users on offline hosts should seed ~/nltk_data ahead of
# time (a bare TaskManager() that loads leaderboard_ifeval is enough
# to trigger the fetch; not gated on actually running an eval).
#
# single-impl: sci-ml/{datasets,evaluate} are SINGLE_IMPL; rest of stack is
# multi-impl, wrapped via python_gen_cond_dep.
RDEPEND="
	>=sci-ml/datasets-2.16.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/evaluate-0.4.0[${PYTHON_SINGLE_USEDEP}]
	vllm? ( >=dev-python/vllm-0.4.2[${PYTHON_SINGLE_USEDEP}] )
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
		ifeval? (
			dev-python/langdetect[${PYTHON_USEDEP}]
			dev-python/immutabledict[${PYTHON_USEDEP}]
			>=dev-python/nltk-3.9.1[${PYTHON_USEDEP}]
		)
		math? (
			=dev-python/antlr4-python3-runtime-4.11*[${PYTHON_USEDEP}]
			>=dev-python/sympy-1.12[${PYTHON_USEDEP}]
			~dev-python/math-verify-0.9.0[${PYTHON_USEDEP}]
		)
		sentencepiece? ( >=sci-ml/sentencepiece-0.1.98[${PYTHON_USEDEP}] )
		statsmodels? ( dev-python/statsmodels[${PYTHON_USEDEP}] )
	')
"
