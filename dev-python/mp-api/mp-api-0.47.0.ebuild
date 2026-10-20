# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

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
KEYWORDS="~amd64 ~arm64"
# Tests require api.materialsproject.org access and an MP_API_KEY.
RESTRICT="test"

RDEPEND="
	>=dev-python/pymatgen-2024.2.21[${PYTHON_SINGLE_USEDEP}]
	>=dev-python/emmet-core-0.88.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/requests-2.23.0[${PYTHON_USEDEP}]
		>=dev-python/monty-2024.12.10[${PYTHON_USEDEP}]
		dev-python/boto3[${PYTHON_USEDEP}]
		>=dev-python/orjson-3.10[${PYTHON_USEDEP}]
		<dev-python/orjson-4[${PYTHON_USEDEP}]
		>=dev-python/pyarrow-20.0.0[${PYTHON_USEDEP}]
		>=dev-python/deltalake-1.4.0[${PYTHON_USEDEP}]
		<dev-python/deltalake-1.6.0[${PYTHON_USEDEP}]
		>=dev-python/rich-13.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/uv-dynamic-versioning[${PYTHON_USEDEP}]
	')
"

# The sdist carries no git metadata for uv-dynamic-versioning to read.
export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
