# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library to write tables in various text/binary formats"
HOMEPAGE="
	https://github.com/thombashi/pytablewriter
	https://pypi.org/project/pytablewriter/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	dev-python/dataproperty[${PYTHON_USEDEP}]
	dev-python/mbstrdecoder[${PYTHON_USEDEP}]
	dev-python/pathvalidate[${PYTHON_USEDEP}]
	dev-python/tabledata[${PYTHON_USEDEP}]
	dev-python/tcolorpy[${PYTHON_USEDEP}]
	dev-python/typepy[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
