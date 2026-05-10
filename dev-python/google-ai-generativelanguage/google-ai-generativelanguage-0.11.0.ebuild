# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# upstream sdist uses underscored normalization
PYPI_PN="google_ai_generativelanguage"
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Google AI generative-language API client (generated GAPIC bindings)"
HOMEPAGE="
	https://github.com/googleapis/google-cloud-python
	https://pypi.org/project/google-ai-generativelanguage/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# google-api-core[grpc] enables grpcio + proto-plus[grpcio] paths upstream
# expects. Listing them explicitly so we don't depend on extra resolution.
RDEPEND="
	>=dev-python/google-api-core-2.11.0[${PYTHON_USEDEP}]
	>=dev-python/google-auth-2.14.1[${PYTHON_USEDEP}]
	>=dev-python/proto-plus-1.22.3[${PYTHON_USEDEP}]
	>=dev-python/protobuf-4.25.8[${PYTHON_USEDEP}]
	>=dev-python/grpcio-1.33.2[${PYTHON_USEDEP}]
"
