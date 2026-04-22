# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Import/export of reduced small-angle scattering data for SasView"
HOMEPAGE="
	https://github.com/SasView/sasdata
	https://pypi.org/project/sasdata/
	https://www.sasview.org/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-requirements-txt[${PYTHON_USEDEP}]
	dev-python/hatch-sphinx[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

src_prepare() {
	# Same treatment as sasmodels: skip the sphinx build hook during
	# wheel construction.
	sed -i \
		-e '/\[\[tool\.hatch\.build\.targets\.wheel\.hooks\.sphinx/,/^\[\[/{/^\[\[tool\.hatch\.build\.targets\.wheel\.hooks\.sphinx/d; /^\[\[/!d}' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
