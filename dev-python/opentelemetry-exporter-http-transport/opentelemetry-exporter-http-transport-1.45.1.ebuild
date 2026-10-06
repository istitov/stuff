# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature

MY_P="opentelemetry-python-${PV}"
DESCRIPTION="OpenTelemetry Exporters HTTP transport"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-exporter-http-transport/
	https://github.com/open-telemetry/opentelemetry-python/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/exporter/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

# The urllib3 extra is unconditional: exporter-otlp-proto-http requires it
# and selects that transport by default.
RDEPEND="
	~dev-python/opentelemetry-api-${PV}[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
# The transport tests mock HTTP with the unpackaged mocket.
EPYTEST_IGNORE=(
	tests/test_requests_transport.py
	tests/test_urllib3_transport.py
)
distutils_enable_tests pytest

pkg_postinst() {
	optfeature "the requests-based HTTP transport" dev-python/requests
}
