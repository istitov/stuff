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
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pymatgen-core-2026.3.9[${PYTHON_SINGLE_USEDEP}]
"

src_prepare() {
	# Upstream split moved phase_diagram, chempot_diagram, and
	# reaction_calculator (plus the pmg CLI) into pymatgen-core. The
	# pymatgen 2026.3.23 sdist was cut before that split and still
	# ships them, which collides with pymatgen-core 2026.3.9+.
	# Drop our copies so pymatgen-core provides the canonical files.
	sed -i -e '/^pmg = "pymatgen\.cli\.pmg:main"$/d' pyproject.toml || die
	rm src/pymatgen/analysis/{phase_diagram,chempot_diagram,reaction_calculator}.py \
		|| die
	distutils-r1_src_prepare
}
