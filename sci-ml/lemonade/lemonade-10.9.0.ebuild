# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Local AI server: optimized LLM inference on AMD NPU + GPU"
HOMEPAGE="
	https://lemonade-server.ai/
	https://github.com/lemonade-sdk/lemonade
"
SRC_URI="https://github.com/lemonade-sdk/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="fastflowlm"

# Upstream's CMake detects nlohmann_json/curl/zstd/CLI11 via pkg-config or
# find_path, but cpp-httplib detection requires a .pc file (which ::gentoo
# doesn't ship) and libwebsockets isn't required at runtime in many ::gentoo
# stacks — so both fall back to FetchContent at configure time. Allow
# network access for that, matching sci-ml/fastflowlm's pattern.
PROPERTIES="live"
RESTRICT="network-sandbox"

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
}

pkg_postinst() {
	elog ""
	elog "Lemonade ${PV} installed."
	elog ""
	elog "Quick start:"
	elog "  lemond                   # start the server (port 13305 by default)"
	elog "  lemonade run <model>     # CLI client"
	elog "  lemonade-server          # deprecated shim that wraps both"
	elog ""
	if use fastflowlm; then
		elog "USE=fastflowlm enabled — the NPU runtime is provided by"
		elog "sci-ml/fastflowlm. Confirm 'flm validate' passes before"
		elog "lemonade tries to drive the NPU backend."
	fi
}
