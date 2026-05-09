# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# upstream sdist uses non-normalized name (underscore)
PYPI_PN="rouge_score"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Pure-python implementation of ROUGE-1.5.5 (text summarization metric)"
HOMEPAGE="
	https://github.com/google-research/google-research/tree/master/rouge
	https://pypi.org/project/rouge-score/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/absl-py[${PYTHON_USEDEP}]
	dev-python/nltk[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"
