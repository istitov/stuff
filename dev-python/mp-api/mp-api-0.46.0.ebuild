# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PN="mp_api"
DESCRIPTION="Client library for accessing the new Materials Project API"
HOMEPAGE="
	https://github.com/materialsproject/api/
	https://pypi.org/project/mp-api/
"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Upstream test suite talks to api.materialsproject.org and needs
# an MP_API_KEY; not runnable at package build time.
RESTRICT="test"

RDEPEND="
	>=dev-python/pymatgen-2022.3.7[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.1[${PYTHON_USEDEP}]
	>=dev-python/requests-2.23.0[${PYTHON_USEDEP}]
	>=dev-python/monty-2024.12.10[${PYTHON_USEDEP}]
	>=dev-python/emmet-core-0.86.3[${PYTHON_USEDEP}]
	dev-python/boto3[${PYTHON_USEDEP}]
	>=dev-python/orjson-3.10[${PYTHON_USEDEP}]
	<dev-python/orjson-4[${PYTHON_USEDEP}]
"
