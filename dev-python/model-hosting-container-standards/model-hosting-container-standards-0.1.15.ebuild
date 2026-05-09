# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python toolkit for standardized model hosting container implementations"
HOMEPAGE="
	https://github.com/aws/model-hosting-container-standards
	https://pypi.org/project/model-hosting-container-standards/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# fastapi lives in ::guru; the rest are in ::gentoo.
RDEPEND="
	dev-python/fastapi[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jmespath[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.49.1[${PYTHON_USEDEP}]
	>=app-admin/supervisor-4.2.0
"
