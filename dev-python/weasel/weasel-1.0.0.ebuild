# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Project-management tooling extracted from ExplosionAI's spaCy"
HOMEPAGE="
	https://github.com/explosion/weasel
	https://pypi.org/project/weasel/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# The 1.0 line exists only on PyPI and satisfies spaCy's >=1,<2 constraint.
# httpx is deprecated in ::gentoo but remains mandatory upstream.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/cloudpathlib-0.7.0[${PYTHON_USEDEP}]
	>=dev-python/confection-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.24.0[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/smart-open-5.2.1[${PYTHON_USEDEP}]
	>=dev-python/srsly-2.4.3[${PYTHON_USEDEP}]
	>=dev-python/typer-0.3.0[${PYTHON_USEDEP}]
	>=dev-python/wasabi-0.9.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
