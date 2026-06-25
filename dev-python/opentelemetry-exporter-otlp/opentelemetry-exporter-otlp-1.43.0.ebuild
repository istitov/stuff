# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P="opentelemetry-python-${PV}"
DESCRIPTION="OpenTelemetry Collector Protobuf over gRPC and HTTP Exporters"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-exporter-otlp/
	https://github.com/open-telemetry/opentelemetry-python/
"
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/exporter/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Convenience umbrella; upstream pins the sub-packages with == in
# pyproject.toml so the version match is exact.
RDEPEND="
	~dev-python/opentelemetry-exporter-otlp-proto-grpc-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-exporter-otlp-proto-http-${PV}[${PYTHON_USEDEP}]
"
