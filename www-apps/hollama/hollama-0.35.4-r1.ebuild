# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Minimal LLM chat UI — SvelteKit + Node, browser-local state"
HOMEPAGE="
	https://github.com/fmaclen/hollama
"

SRC_URI="
	https://github.com/fmaclen/hollama/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="openrc systemd"

# The docker-node adapter emits a self-contained bundle; runtime needs only
# the Node interpreter.
RDEPEND="
	>=net-libs/nodejs-20
"
BDEPEND="
	>=net-libs/nodejs-20[npm]
"

# The large, volatile npm graph is not vendored; build requires registry access.
PROPERTIES="live"
RESTRICT="network-sandbox"

src_compile() {
	einfo "Installing npm dependencies (downloads from registry.npmjs.org)..."
	npm ci --no-audit --no-fund \
		|| die "npm ci failed"

	einfo "Building SvelteKit Node bundle..."
	PUBLIC_ADAPTER=docker-node npm run build \
		|| die "vite build failed"

	[[ -f build/index.js ]] \
		|| die "expected build/index.js after npm run build"
}

src_install() {
	# Keep the self-contained application under /opt; expose only its wrapper.
	insinto /opt/hollama
	doins -r build

	newbin "${FILESDIR}"/hollama.bin hollama

	# conf.d is OpenRC-only; the systemd unit uses DynamicUser.
	if use systemd; then
		systemd_dounit "${FILESDIR}"/hollama.service
	fi
	if use openrc; then
		newinitd "${FILESDIR}"/hollama.initd hollama
		newconfd "${FILESDIR}"/hollama.confd hollama
	fi

	dodoc README.md SELF_HOSTING.md
}

pkg_postinst() {
	elog ""
	elog "Hollama ${PV} installed to /opt/hollama, served by /usr/bin/hollama."
	elog ""
	elog "Quick start (foreground):"
	elog "  hollama"
	elog "  # then visit http://127.0.0.1:4173"
	elog ""
	elog "As a service:"
	elog "  systemd:  systemctl enable --now hollama"
	elog "  openrc:   rc-service hollama start && rc-update add hollama"
	elog ""
	elog "Defaults in /etc/conf.d/hollama (HOLLAMA_HOST defaults to"
	elog "127.0.0.1 — set to 0.0.0.0 to expose on the LAN). Hollama has"
	elog "no built-in auth; chat state is stored in your browser's"
	elog "localStorage so no server-side data leaks, but anyone with"
	elog "network reach could drive your local LLM through it."
	elog ""
	elog "Backends: any OpenAI-compatible HTTP endpoint plus Ollama"
	elog "natively. Pairs with sci-misc/llama-cpp, sci-misc/llama-swap,"
	elog "dev-python/vllm, sci-ml/lemonade."
}
