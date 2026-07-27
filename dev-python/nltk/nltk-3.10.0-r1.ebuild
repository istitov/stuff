# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Natural Language Toolkit for Python"
HOMEPAGE="
	https://www.nltk.org/
	https://github.com/nltk/nltk
	https://pypi.org/project/nltk/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# defusedxml is new in 3.10.0 (3.9.4 does not require it) and is not
# optional: __init__.py imports nltk.downloader at module scope, which
# imports defusedxml.ElementTree at module scope, so a plain `import nltk`
# raises ImportError without it. Also imported the same way by
# corpus/reader/xmldocs.py and nombank.py, where upstream switched to
# defusedxml to reject entity-expansion attacks in untrusted corpus XML.
# verified 2026-07-27
RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/defusedxml[${PYTHON_USEDEP}]
	dev-python/joblib[${PYTHON_USEDEP}]
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"
