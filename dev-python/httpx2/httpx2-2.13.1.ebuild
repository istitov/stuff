# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 optfeature

DESCRIPTION="Next generation HTTP client (Pydantic's httpx successor)"
HOMEPAGE="
	https://github.com/pydantic/httpx2
	https://pypi.org/project/httpx2/
"
# The sdist's readme hook reads ../../README.md, which only the monorepo
# tag carries.
SRC_URI="
	https://github.com/pydantic/httpx2/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${P}/src/${PN}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cli"

# httpcore2 is pinned to the same release upstream.
RDEPEND="
	>=dev-python/anyio-4.10[${PYTHON_USEDEP}]
	~dev-python/httpcore2-${PV}[${PYTHON_USEDEP}]
	>=dev-python/idna-3.18[${PYTHON_USEDEP}]
	>=dev-python/truststore-0.10[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
	' 3.12)
	cli? (
		>=dev-python/click-8.4.2[${PYTHON_USEDEP}]
		=dev-python/pygments-2*[${PYTHON_USEDEP}]
		>=dev-python/rich-10[${PYTHON_USEDEP}]
		<dev-python/rich-16[${PYTHON_USEDEP}]
	)
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
	>=dev-python/uv-dynamic-versioning-0.14.1[${PYTHON_USEDEP}]
"

export UV_DYNAMIC_VERSIONING_BYPASS=${PV}

pkg_postinst() {
	optfeature "HTTP/2 support" dev-python/h2
	optfeature "SOCKS proxy support" dev-python/socksio
	optfeature "WebSocket support" dev-python/wsproto
	optfeature "brotli decoding" "app-arch/brotli[python]" dev-python/brotlicffi
	optfeature "zstd decoding on Python < 3.14" dev-python/backports-zstd
}
