# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Pyshortcuts helps to create desktop shortcuts that will run python scripts"
HOMEPAGE="https://github.com/newville/pyshortcuts"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# platformdirs is NEW in 1.9.10 (1.9.9's requires-dist has no such entry) and is
# a top-level `import platformdirs` in pyshortcuts/utils.py, which the package
# root imports -- so it is unconditional, not a lazy per-platform import despite
# also appearing in windows.py/darwin.py. verified 2026-09-01
RDEPEND="
	dev-python/charset-normalizer[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-4.11.3[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
