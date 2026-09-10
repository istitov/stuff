# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Python Materials Genomics (umbrella shim over pymatgen-core)"
HOMEPAGE="
	https://github.com/materialsproject/pymatgen/
	https://pypi.org/project/pymatgen/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pymatgen-core-2026.4.16[${PYTHON_SINGLE_USEDEP}]
"

src_prepare() {
	# The module split is complete, but this sdist still exposes pmg; keep
	# pymatgen-core as its canonical provider.
	grep -qF 'pmg = "pymatgen.cli.pmg:main"' pyproject.toml ||
		die "pmg script anchor moved"
	sed -i -e '/^pmg = "pymatgen\.cli\.pmg:main"$/d' pyproject.toml || die
	distutils-r1_src_prepare
}
