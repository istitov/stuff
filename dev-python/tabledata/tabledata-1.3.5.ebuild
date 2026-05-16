# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library to represent / process tabular data"
HOMEPAGE="
	https://github.com/thombashi/tabledata
	https://pypi.org/project/tabledata/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/dataproperty-1.0.2[${PYTHON_USEDEP}]
	>=dev-python/typepy-1.2.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
