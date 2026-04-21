# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

MY_PN="emmet_core"
DESCRIPTION="Core Emmet data models for the Materials Project"
HOMEPAGE="
	https://github.com/materialsproject/emmet/
	https://pypi.org/project/emmet-core/
"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
# Upstream's test suite expects the full Materials Project test data
# fixtures from the emmet monorepo; not shipped in the emmet-core
# sdist, so the bundled tests directory is unrunnable on its own.
RESTRICT="test"

RDEPEND="
	>=dev-python/pymatgen-2024.6.10[${PYTHON_USEDEP}]
	>=dev-python/monty-2024.2.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.0[${PYTHON_USEDEP}]
	>=dev-python/pymatgen-io-validation-0.1.1[${PYTHON_USEDEP}]
	~dev-python/pybtex-0.24[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7[${PYTHON_USEDEP}]
	dev-python/blake3[${PYTHON_USEDEP}]
"
