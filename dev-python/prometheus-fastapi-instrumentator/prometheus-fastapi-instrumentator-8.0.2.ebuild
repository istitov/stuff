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

distutils_enable_tests unittest

python_test() {
	"${EPYTHON}" - <<-'PY' || die
		from prometheus_client import CollectorRegistry
		from starlette.applications import Starlette
		from prometheus_fastapi_instrumentator import Instrumentator, metrics

		registry = CollectorRegistry()
		app = Starlette()
		instrumentator = Instrumentator(registry=registry)
		instrumentator.add(metrics.default(registry=registry))
		assert instrumentator.instrument(app).expose(app) is instrumentator
		assert len(app.user_middleware) == 1
		assert any(getattr(route, "path", None) == "/metrics" for route in app.routes)
	PY
}
