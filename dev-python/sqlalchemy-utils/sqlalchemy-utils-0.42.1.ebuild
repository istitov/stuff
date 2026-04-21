# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PN="sqlalchemy_utils"
DESCRIPTION="Various utility functions and datatypes for SQLAlchemy"
HOMEPAGE="
	https://github.com/kvesteri/sqlalchemy-utils/
	https://pypi.org/project/SQLAlchemy-Utils/
"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# Upstream test suite requires a live PostgreSQL/MySQL/etc. server;
# not runnable at package build time.
RESTRICT="test"

RDEPEND="
	>=dev-python/sqlalchemy-1.4[${PYTHON_USEDEP}]
"
