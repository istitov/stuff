# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# upstream PyPI sdist filename uses underscore (latex2sympy2_extended-x.y.z.tar.gz),
# project page is /pypi/latex2sympy2-extended/
PYPI_PN="latex2sympy2_extended"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Convert LaTeX math to SymPy expressions"
# Upstream pyproject.toml's Project-URL still points to OrangeX4 (the repo
# this fork was originally adapted from); that repo was deleted 2026-05-x
# (HTTP 404 verified 2026-05-18), so only the live huggingface fork + PyPI
# remain.
HOMEPAGE="
	https://github.com/huggingface/latex2sympy2_extended
	https://pypi.org/project/latex2sympy2-extended/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Core deps from pyproject.toml [project.dependencies] at v1.11.0.
# antlr4-python3-runtime range >=4.9.3,<=4.13.2; ::gentoo carries 4.13.2
# which sits at the upper end of the supported range.
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/sympy[${PYTHON_USEDEP}]
		>=dev-python/antlr4-python3-runtime-4.9.3[${PYTHON_USEDEP}]
		<dev-python/antlr4-python3-runtime-4.14[${PYTHON_USEDEP}]
	')
"

# Tests not wired: upstream sdist excludes the tests/ directory entirely
# (verified 2026-05-11 — pyproject.toml declares [tool.pytest.ini_options]
# testpaths = ["tests"] but no tests/ ships in the v1.11.0 sdist), so
# distutils_enable_tests pytest would have nothing to run.
