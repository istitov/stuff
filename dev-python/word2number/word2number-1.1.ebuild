# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Convert number words (e.g. three hundred and forty two) to numbers (342)"
HOMEPAGE="
	https://github.com/akshaynagpal/w2n
	https://pypi.org/project/word2number/
"

# upstream sdist on PyPI is .zip, override pypi.eclass default of .tar.gz
SRC_URI="$(pypi_sdist_url "${PYPI_PN}" "${PV}" .zip)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

BDEPEND="app-arch/unzip"
