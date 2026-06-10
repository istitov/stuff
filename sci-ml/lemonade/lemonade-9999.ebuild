# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Local AI server: optimized LLM inference on AMD NPU + GPU"
HOMEPAGE="
	https://lemonade-server.ai/
	https://github.com/lemonade-sdk/lemonade
"

EGIT_REPO_URI="https://github.com/lemonade-sdk/${PN}.git"

LICENSE="Apache-2.0"
SLOT="0"
# No KEYWORDS for live ebuild.
IUSE="fastflowlm"

# cpp-httplib + libwebsockets fall back to FetchContent under default ::gentoo
# system deps; allow network access at build time for that.
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

	# ::gentoo's cpp-httplib ships no pkg-config .pc, so upstream's
	# detection misses it and the build FetchContents cpp-httplib at
	# v${MIN_HTTPLIB_VERSION} (0.26.0 at HEAD). That tag's own
	# CMakeLists.txt has a malformed
	# `if(CMAKE_SYSTEM_NAME MATCHES "Windows" AND VERSION_LESS 10.0.0)`
	# which CMake 4 rejects ("Unknown arguments specified"). Pin the
	# fetch to v0.38.0 — the CMake-4-clean version we ship as
	# dev-cpp/cpp-httplib. Same fix as 10.7.0; the GIT_TAG line is
	# matched by variable, so it holds across HEAD bumps unless upstream
	# raises MIN_HTTPLIB_VERSION past 0.38.0. confirmed at HEAD 2026-06-10
	sed -i \
		-e 's|GIT_TAG v${MIN_HTTPLIB_VERSION}|GIT_TAG v0.38.0|' \
		CMakeLists.txt || die
}

src_configure() {
	# /usr matches lemond's get_resource_path() search list (see release ebuild).
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_WEB_APP=OFF
		-DBUILD_TAURI_APP=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	find "${ED}" -name 'libwebsockets.a' -delete || die
}

pkg_postinst() {
	elog ""
	elog "Lemonade ${PV} (live) installed."
	elog ""
	elog "Quick start:"
	elog "  lemond                   # start the server (port 13305 by default)"
	elog "  lemonade run <model>     # CLI client"
	elog ""
	elog "Live ebuild — rebuild via: emerge --oneshot =sci-ml/lemonade-9999"
	elog ""
	if use fastflowlm; then
		elog "USE=fastflowlm enabled — the NPU runtime is provided by"
		elog "sci-ml/fastflowlm. Confirm 'flm validate' passes before"
		elog "lemonade tries to drive the NPU backend."
	fi
}
