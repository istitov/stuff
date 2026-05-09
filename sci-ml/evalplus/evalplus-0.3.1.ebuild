# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Rigorous evaluation of LLM-synthesised code (HumanEval+, MBPP+)"
HOMEPAGE="
	https://github.com/evalplus/evalplus
	https://pypi.org/project/evalplus/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="perf"

RDEPEND="
	dev-python/anthropic[${PYTHON_USEDEP}]
	dev-python/appdirs[${PYTHON_USEDEP}]
	>=dev-python/fire-0.6.0[${PYTHON_USEDEP}]
	>=dev-python/google-generativeai-0.7.2[${PYTHON_USEDEP}]
	dev-python/multipledispatch[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/openai-1.11.1[${PYTHON_USEDEP}]
	>=dev-python/psutil-5.9.0[${PYTHON_USEDEP}]
	>=dev-python/rich-12.3.0[${PYTHON_USEDEP}]
	dev-python/stop-sequencer[${PYTHON_USEDEP}]
	dev-python/tempdir[${PYTHON_USEDEP}]
	>=dev-python/termcolor-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.56.0[${PYTHON_USEDEP}]
	>=dev-python/tree-sitter-0.22.0[${PYTHON_USEDEP}]
	>=dev-libs/tree-sitter-python-0.21.0[python(+),${PYTHON_USEDEP}]
	dev-python/wget[${PYTHON_USEDEP}]
	>=sci-ml/datasets-2.21.0[${PYTHON_USEDEP}]
	>=sci-ml/transformers-4.43.0[${PYTHON_USEDEP}]
	perf? (
		>=dev-python/cirron-0.4[${PYTHON_USEDEP}]
		>=dev-python/pympler-1.0.1[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

# pyproject sets version via setuptools_scm; sdist has no .git
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
