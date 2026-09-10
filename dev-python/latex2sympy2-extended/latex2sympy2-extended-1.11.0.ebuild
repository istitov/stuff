# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# The sdist name uses underscores while the project name uses hyphens.
PYPI_PN="latex2sympy2_extended"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Convert LaTeX math to SymPy expressions"
# Ignore the deleted legacy Project-URL; use the live fork and PyPI.
HOMEPAGE="
	https://github.com/huggingface/latex2sympy2_extended
	https://pypi.org/project/latex2sympy2-extended/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Preserve upstream's antlr4-python3-runtime range through 4.13.2.
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/sympy[${PYTHON_USEDEP}]
		>=dev-python/antlr4-python3-runtime-4.9.3[${PYTHON_USEDEP}]
		<dev-python/antlr4-python3-runtime-4.13.3[${PYTHON_USEDEP}]
	')
"

# The sdist omits its configured tests directory. verified 2026-05-11
