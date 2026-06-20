# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Enthought Tool Suite: Explicitly typed attributes for Python"
HOMEPAGE="https://code.enthought.com/projects/traits/ https://pypi.python.org/pypi/traits"

SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"
#S=${WORKDIR}/${P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc examples test"
RESTRICT="!test? ( test )"

RDEPEND="dev-python/numpy"
DEPEND="dev-python/setuptools
	doc? ( dev-python/sphinx )
	test? ( dev-python/numpy )"

#DOCS="docs/*.txt"
