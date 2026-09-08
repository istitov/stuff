# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN=dans_diffraction
#PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Generate diffracted intensities from crystals"
HOMEPAGE="https://danporter.github.io/Dans_Diffraction/"
#SRC_URI="$(pypi_sdist_url --no-normalize "${MYPN}" "${PV}")"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

src_prepare() {
	default

	# Upstream declares the same launcher as both a console and GUI script.
	# installer refuses to overwrite the first generated file with the second.
	sed -i -e '/^\[project.gui-scripts\]/,/^$/s/^dansdiffraction = .*//' \
		pyproject.toml || die
}
