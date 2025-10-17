# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=hatchling
inherit distutils-r1 pypi

#MYPN="${PN/_/-}"
#MYP="${MYPN}-${PV}"

DESCRIPTION="Artist for matplotlib to display a scale bar"
HOMEPAGE="https://github.com/ppinard/matplotlib-scalebar"
#SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"
#S=${WORKDIR}/${MYP}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python test"

RDEPEND="
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	test? ( dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/pytest-cov[${PYTHON_USEDEP}]
		dev-util/ruff[${PYTHON_USEDEP}]
	)
"
