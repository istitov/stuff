# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="primePy"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Functions for working with prime numbers (factorization, totient, etc.)"
HOMEPAGE="
	https://github.com/janaindrajit/primePy
	https://pypi.org/project/primePy/
"
# Predates PEP 625; sdist filename preserves camelCase PyPI name.
SRC_URI="$(pypi_sdist_url --no-normalize)"
S="${WORKDIR}/${PYPI_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
