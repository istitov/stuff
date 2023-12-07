# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYPI_PN=${PN/-/_}
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="Generate diffracted intensities from crystals"
HOMEPAGE="https://danporter.github.io/Dans_Diffraction/"
#SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
