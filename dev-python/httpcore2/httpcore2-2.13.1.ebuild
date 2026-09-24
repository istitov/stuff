# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature

DESCRIPTION="Minimal low-level HTTP client (Pydantic's httpcore successor)"
HOMEPAGE="
	https://github.com/pydantic/httpx2
	https://pypi.org/project/httpcore2/
"
# httpcore2 and httpx2 are built from one monorepo tag; the sdists are not
# self-contained (httpx2's readme hook reads ../../README.md).
SRC_URI="
	https://github.com/pydantic/httpx2/archive/refs/tags/v${PV}.tar.gz
		-> httpx2-${PV}.gh.tar.gz
"
S="${WORKDIR}/httpx2-${PV}/src/${PN}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/h11-0.16[${PYTHON_USEDEP}]
	>=dev-python/truststore-0.10[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
	>=dev-python/uv-dynamic-versioning-0.14.1[${PYTHON_USEDEP}]
"

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}

pkg_postinst() {
	optfeature "asyncio support" dev-python/anyio
	optfeature "trio support" dev-python/trio
	optfeature "HTTP/2 support" dev-python/h2
	optfeature "SOCKS proxy support" dev-python/socksio
}
