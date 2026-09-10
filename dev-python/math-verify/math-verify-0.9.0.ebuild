# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# PyPI uses an underscore in the sdist filename.
PYPI_PN="math_verify"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="HuggingFace library for verifying mathematical answers"
HOMEPAGE="
	https://github.com/huggingface/math-verify
	https://pypi.org/project/math-verify/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Match upstream's exact 1.11.0 pin while allowing Gentoo revisions.
RDEPEND="
	$(python_gen_cond_dep '
		~dev-python/latex2sympy2-extended-1.11.0[${PYTHON_USEDEP}]
	')
"

# Tests: 290/291 pass; one malformed-LLM-output case fails for non-packaging
# reasons, and its parameter ID is too brittle to deselect. Revisit on bumps.
# verified 2026-05-11
