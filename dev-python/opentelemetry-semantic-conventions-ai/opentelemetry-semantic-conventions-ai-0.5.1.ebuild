# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="OpenTelemetry Semantic Conventions extension for Large Language Models"
HOMEPAGE="
	https://github.com/traceloop/openllmetry
	https://pypi.org/project/opentelemetry-semantic-conventions-ai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Layered on top of stock opentelemetry-semantic-conventions in ::gentoo.
RDEPEND="
	>=dev-python/opentelemetry-sdk-1.38.0[${PYTHON_USEDEP}]
	dev-python/opentelemetry-semantic-conventions[${PYTHON_USEDEP}]
"
