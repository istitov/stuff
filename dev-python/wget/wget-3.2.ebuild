# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Pure-python download utility (PyPI 'wget' module)"
HOMEPAGE="https://pypi.org/project/wget/"

# upstream sdist on PyPI is .zip
SRC_URI="$(pypi_sdist_url "${PYPI_PN}" "${PV}" .zip)"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

BDEPEND="app-arch/unzip"
