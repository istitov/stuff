# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PV="${PV/_p/.post}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Python package for configuring a python package"
HOMEPAGE="
	https://github.com/pytroll/donfig
	https://pypi.org/project/donfig/
"
SRC_URI="$(pypi_sdist_url "${PN}" "${MY_PV}")"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/versioneer[${PYTHON_USEDEP}]
"
