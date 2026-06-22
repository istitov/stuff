# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Set of Python modules for atomistic simulations"
HOMEPAGE="https://wiki.fysik.dtu.dk/ase"
#SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc examples test"
RESTRICT="!test? ( test )"
PYTHON_REQ_USE="tk"

RDEPEND="${PYTHON_DEPS}
	dev-python/numpy
	dev-python/scipy
	dev-python/matplotlib
	dev-python/typing-extensions
	dev-python/psycopg
	"
#psycopg2-binary
DEPEND="dev-python/setuptools"
