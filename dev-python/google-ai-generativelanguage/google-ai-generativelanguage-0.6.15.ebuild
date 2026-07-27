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

# Upstream requires google-api-core[grpc]. ::gentoo models that extra as a USE
# flag gating grpcio AND grpcio-status, so ask for the flag rather than
# re-listing its contents: the previous enumeration here had already drifted,
# carrying grpcio but not grpcio-status. grpcio stays declared because upstream
# names it separately from the extra. verified 2026-07-27
RDEPEND="
	>=dev-python/google-api-core-1.34.1[grpc,${PYTHON_USEDEP}]
	>=dev-python/google-auth-2.14.1[${PYTHON_USEDEP}]
	>=dev-python/proto-plus-1.22.3[${PYTHON_USEDEP}]
	dev-python/protobuf[${PYTHON_USEDEP}]
	dev-python/grpcio[${PYTHON_USEDEP}]
"
