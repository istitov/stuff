# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Reliable LLM model swapping proxy for llama.cpp / vllm / etc."
HOMEPAGE="
	https://github.com/mostlygeek/llama-swap
"

# extra-stuff vendors the Go module set for network-sandboxed builds; its tag,
# not the bundle filename, carries the revision.
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
KEYWORDS="~amd64 ~arm64"
IUSE="openrc systemd ui"

BDEPEND="
	>=dev-lang/go-1.27.0
	ui? ( net-libs/nodejs[npm] )
"

# USE=ui fetches the large, bump-sensitive Svelte dependency set from npm,
# matching sci-misc/llama-cpp's web UI model.
PROPERTIES="ui? ( live )"
RESTRICT="ui? ( network-sandbox )"

src_compile() {
	# Since 251, embed_ui controls Vite output in internal/server/ui_dist;
	# !embed_ui supplies the no-UI implementation. At 253 the lockfile, output,
	# tag pair, and main.version ldflag target remain valid. # verified 2026-09-04
	local build_tags=()
	if use ui; then
		pushd ui > /dev/null || die
		# npm ci requires upstream's committed lockfile.
		npm ci --no-audit --no-fund || die "npm ci failed"
		npm run build || die "vite build failed"
		popd > /dev/null || die
		build_tags=( -tags embed_ui )
	fi

	ego build "${build_tags[@]}" \
		-ldflags="-X main.version=${PV}" \
		-o "${PN}" .
}

src_install() {
	dobin "${PN}"

	insinto /usr/share/${PN}
	# The root file is only a pointer; install the real reference config.
	# verified 2026-09-09
	doins docs/config.example.yaml

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
