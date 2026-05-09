# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Wrappers for the Moses tokenizer/detokenizer/punctuation-normaliser"
HOMEPAGE="
	https://github.com/luismsgomes/mosestokenizer
	https://pypi.org/project/mosestokenizer/
"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-lang/perl
	dev-python/docopt[${PYTHON_USEDEP}]
	dev-python/openfile[${PYTHON_USEDEP}]
	dev-python/uctools[${PYTHON_USEDEP}]
	dev-python/toolwrapper[${PYTHON_USEDEP}]
"
