# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_PN=dans_diffraction
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Generate diffracted intensities from crystals"
HOMEPAGE="https://danporter.github.io/Dans_Diffraction/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	>=dev-python/scipy-0.15[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
"

src_prepare() {
	default

	# Drop the duplicate GUI entry; installer will not overwrite the console script.
	grep -qF '[project.gui-scripts]' pyproject.toml ||
		die "project.gui-scripts anchor moved"
	sed -i -e '/^\[project.gui-scripts\]/,/^$/s/^dansdiffraction = .*//' \
		pyproject.toml || die
}
