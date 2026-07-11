# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

DESCRIPTION="Local AI server: optimized LLM inference on AMD NPU + GPU"
HOMEPAGE="
	https://lemonade-server.ai/
	https://github.com/lemonade-sdk/lemonade
"
SRC_URI="https://github.com/lemonade-sdk/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="fastflowlm openrc systemd"

# Upstream's CMake detects nlohmann_json/curl/zstd/CLI11 via pkg-config or
# find_path, but cpp-httplib detection requires a .pc file (which ::gentoo
# doesn't ship) and libwebsockets isn't required at runtime in many ::gentoo
# stacks — so both fall back to FetchContent at configure time. Allow
# network access for that, matching sci-ml/fastflowlm's pattern.
PROPERTIES="live"
RESTRICT="network-sandbox"

# acct-user/lemonade backs the systemd unit's User=lemonade. Pulled
# unconditionally (matching sci-ml/ollama's acct-user) so toggling
# USE=systemd can't orphan the /var/lib/lemonade state dir; the OpenRC
# service ignores this account and runs as LEMONADE_USER instead.
RDEPEND="
	app-arch/brotli:=
	app-arch/zstd:=
	>=dev-cpp/cli11-2.4.2
	>=dev-cpp/cpp-httplib-0.26.0
	>=dev-cpp/nlohmann_json-3.11.3
	>=net-libs/libwebsockets-4.3.3
	>=net-misc/curl-8.5.0
	sys-libs/libcap
	fastflowlm? ( sci-ml/fastflowlm )
	acct-user/lemonade
	acct-group/lemonade
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.12
	virtual/pkgconfig
"

src_prepare() {
	cmake_src_prepare

	# ::gentoo ships cpp-httplib's CMake config but no pkg-config .pc,
	# while upstream detects it only via pkg_search_module — so the build
	# FetchContents cpp-httplib at v${MIN_HTTPLIB_VERSION} (0.26.0).
	# That tag's own CMakeLists.txt has a malformed
	# `if(CMAKE_SYSTEM_NAME MATCHES "Windows" AND VERSION_LESS 10.0.0)`
	# which CMake 4 rejects ("Unknown arguments specified"). Pin the
	# fetch to v0.38.0 — the CMake-4-clean version we ship as
	# dev-cpp/cpp-httplib, API-compatible with the >=0.26.0 floor lemonade
	# actually needs. verified 2026-06-10
	sed -i \
		-e 's|GIT_TAG v${MIN_HTTPLIB_VERSION}|GIT_TAG v0.38.0|' \
		CMakeLists.txt || die
}

src_configure() {
	# BUILD_WEB_APP defaults ON on Linux but pulls Node.js + npm install
	# at build time; BUILD_TAURI_APP brings cargo + Rust GUI bundling.
	# Both are off here for a server-only build; revisit if a USE flag is
	# requested for the desktop GUI.
	#
	# Upstream defaults to /opt as the prefix for Linux, but lemond's
	# get_resource_path() searches /usr/share/lemonade-server/ and
	# /opt/share/lemonade-server/ — the /opt branch wants resources at
	# the *top* of /opt, not under /opt/lemonade/. /usr matches their
	# .deb/.rpm layout and lets the resources resolve cleanly.
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_WEB_APP=OFF
		-DBUILD_TAURI_APP=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# FetchContent-built libwebsockets installs its static archive into
	# the prefix; we don't need it shipped (lemond linked against it
	# statically already, no consumers).
	find "${ED}" -name 'libwebsockets.a' -delete || die

	# Upstream's CMake unconditionally installs systemd units (system +
	# user), plus a migrate-to-systemd helper. Gate them behind
	# USE=systemd: the system unit runs as User=lemonade (provided by
	# acct-user/lemonade). Without USE=systemd, strip them so OpenRC (or
	# unit-less) installs don't carry dead units.
	#
	# The three paths below mirror exactly what upstream's CMake installs
	# as of v10.10.0. On a bump, re-confirm the unit basename, the migrate
	# helper path and that examples/ still exists -- a rename upstream
	# turns any of these `rm ... || die` into a build failure.
	# verified 2026-07-11
	if ! use systemd; then
		# systemd_get_*unitdir already carries EPREFIX, so pair it with
		# ${D} (not ${ED}) to avoid a doubled prefix.
		rm "${D}$(systemd_get_systemunitdir)/lemond.service" || die
		rm "${D}$(systemd_get_userunitdir)/lemond.service" || die
		rm "${ED}/usr/share/lemonade-server/examples/migrate-to-systemd.sh" || die
		rmdir "${ED}/usr/share/lemonade-server/examples" 2>/dev/null || true
	fi

	if use openrc; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	fi
}

pkg_postinst() {
	elog ""
	elog "Lemonade ${PV} installed. lemond binds 127.0.0.1:13305 (loopback)"
	elog "by default; expose it beyond localhost only behind API-key auth"
	elog "(LEMONADE_API_KEY) or an SSH tunnel / WireGuard."
	elog ""
	ewarn "Privacy: at startup lemond sends a UDP presence broadcast on LAN"
	ewarn "(RFC1918) interfaces -- on by default, and it fires even with the"
	ewarn "loopback bind. Disable it by setting no_broadcast to true in"
	ewarn "~/.cache/lemonade/config.json."
	elog ""
	elog "Data lives under ~/.cache/lemonade (config + models) and"
	elog "~/.cache/huggingface (model cache + HF_TOKEN if set); model pulls"
	elog "fetch from HuggingFace over the network."
	elog ""
	elog "Quick start (manual):"
	elog "  lemond                   # start the server (port 13305 by default)"
	elog "  lemonade run <model>     # CLI client"
	elog "  lemonade-server          # deprecated shim that wraps both"
	elog ""
	if use openrc; then
		elog "OpenRC service (supervise-daemon; auto-restart on crash):"
		elog "  edit /etc/conf.d/lemonade and set LEMONADE_USER (required)"
		elog "  the --host default (127.0.0.1) keeps it loopback-only"
		elog "  rc-service lemonade start"
		elog "  rc-update add lemonade default       # auto-start at boot"
		elog ""
	fi
	if use systemd; then
		elog "systemd service (runs as the dedicated 'lemonade' user):"
		elog "  systemctl enable --now lemond          # system-wide, or"
		elog "  systemctl --user enable --now lemond   # per-user"
		elog "  host/port live in config.json, not env vars; HF_TOKEN and"
		elog "  LEMONADE_API_KEY go in /etc/lemonade/conf.d/*.conf"
		elog ""
	fi
	if use fastflowlm; then
		elog "USE=fastflowlm enabled — the NPU runtime is provided by"
		elog "sci-ml/fastflowlm. Confirm 'flm validate' passes before"
		elog "lemonade tries to drive the NPU backend."
	fi
}
