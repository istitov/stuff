# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Reliable LLM model swapping proxy for llama.cpp / vllm / etc."
HOMEPAGE="
	https://github.com/mostlygeek/llama-swap
"

# Vendored upstream source bundle hosted on extra-stuff to keep the
# Go module set network-sandbox-friendly. Bundle filename has no
# revision; the tag carries -rN-N (extra-stuff convention) and the
# rename suffix matches.
MY_EXTRA_TAG="${PN}-${PV}-r0-0"
MY_EXTRA_PATH="sci-misc/${PN}/${PN}-${PV}.tar.xz"
MY_EXTRA_DISTFILE="${MY_EXTRA_TAG}.tar.xz"
SRC_URI="
	https://raw.githubusercontent.com/istitov/extra-stuff/${MY_EXTRA_TAG}/${MY_EXTRA_PATH} -> ${MY_EXTRA_DISTFILE}
	https://codeberg.org/istitov/extra-stuff/raw/tag/${MY_EXTRA_TAG}/${MY_EXTRA_PATH} -> ${MY_EXTRA_DISTFILE}
	https://gitlab.com/istitov/extra-stuff/-/raw/${MY_EXTRA_TAG}/${MY_EXTRA_PATH} -> ${MY_EXTRA_DISTFILE}
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="openrc systemd ui"

BDEPEND="
	>=dev-lang/go-1.26.1
	ui? ( net-libs/nodejs[npm] )
"

# Svelte UI is fetched from the npm registry via `npm install` when
# USE=ui is set; can't be pre-vendored sanely (npm dep set is huge
# and re-resolves on every upstream UI bump). Mirrors how
# sci-misc/llama-cpp provisions its own webui at configure time.
PROPERTIES="ui? ( live )"
RESTRICT="ui? ( network-sandbox )"

src_compile() {
	if use ui; then
		pushd ui-svelte > /dev/null || die
		# `npm ci` would also work but requires committed package-lock
		# (which upstream does ship); `npm install` is more forgiving
		# if the lock and package.json drift between bumps.
		npm ci --no-audit --no-fund || die "npm install failed"
		npm run build || die "vite build failed"
		popd > /dev/null || die
	else
		# proxy/ui_embed.go uses `//go:embed ui_dist`, which requires
		# at least one file in the embed directory. Stub it with a
		# minimal index.html so the build succeeds and any UI route
		# returns a useful "rebuild with USE=ui" message instead of
		# 404 garbage.
		mkdir -p proxy/ui_dist || die
		cat > proxy/ui_dist/index.html <<-EOF || die
		<!DOCTYPE html>
		<title>llama-swap</title>
		<h1>llama-swap web UI disabled</h1>
		<p>This llama-swap was built with USE=-ui. The HTTP API is
		fully functional; rebuild with USE=ui to enable the embedded
		Svelte UI.</p>
		EOF
	fi

	ego build \
		-ldflags="-X main.version=${PV}" \
		-o "${PN}" .
}

src_install() {
	dobin "${PN}"

	insinto /usr/share/${PN}
	doins config.example.yaml

	if use openrc; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	fi
	if use systemd; then
		systemd_newunit "${FILESDIR}/${PN}.service" "${PN}@.service"
	fi

	einstalldocs
}

pkg_postinst() {
	elog ""
	elog "llama-swap ${PV} installed."
	elog ""
	elog "Quick start (manual):"
	elog "  cp /usr/share/${PN}/config.example.yaml ~/.config/llama-swap.yaml"
	elog "  edit ~/.config/llama-swap.yaml to register your local llm servers"
	elog "  llama-swap --config ~/.config/llama-swap.yaml --listen :8080"
	elog ""
	if use openrc; then
		elog "OpenRC service (supervise-daemon; auto-restart on crash):"
		elog "  edit /etc/conf.d/llama-swap and set LLAMA_SWAP_USER (required)"
		elog "  rc-service llama-swap start"
		elog "  rc-update add llama-swap default      # auto-start at boot"
		elog ""
	fi
	if use systemd; then
		elog "systemd template service (one instance per user):"
		elog "  create /etc/default/llama-swap@<user> with at least"
		elog "    LLAMA_SWAP_CONFIG=/path/to/llama-swap.yaml"
		elog "  (LLAMA_SWAP_LISTEN / LLAMA_SWAP_EXTRA_OPTS are optional)"
		elog "  systemctl enable --now llama-swap@<user>.service"
		elog ""
	fi
	if ! use ui; then
		elog "Web UI disabled (USE=-ui). API still works; emerge with"
		elog "USE=ui to enable the embedded Svelte interface (pulls in"
		elog "net-libs/nodejs and runs npm at build time)."
		elog ""
	fi
}
