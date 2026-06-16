# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Instrument your FastAPI app with Prometheus metrics"
HOMEPAGE="
	https://github.com/trallnag/prometheus-fastapi-instrumentator
	https://pypi.org/project/prometheus-fastapi-instrumentator/
"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/starlette-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/prometheus-client-0.8.0[${PYTHON_USEDEP}]
"
