# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Component Unified Identifier: deterministic hardware IDs for GPUs, CPUs and NICs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/cuid"
# AMD retired rocm-* releases; use the cuid asset from the matching TheRock
# release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/cuid.tar.gz -> cuid-${PV}.tar.gz"
S="${WORKDIR}/cuid"

LICENSE="MIT"
# Slot by ROCm release, not upstream's 0.x library version.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64"

IUSE="examples test"
RESTRICT="!test? ( test )"

# Without system OpenSSL, upstream FetchContent-clones a vendored copy during
# configuration, violating network sandbox. # verified 2026-08-31
RDEPEND="
	dev-libs/openssl:=
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		# Override upstream's non-forced "lib" cache default.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		# The daemon needs an account and OpenRC integration not provided here;
		# retain upstream's OFF default.
		-DBUILD_DAEMON=OFF
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTS=$(usex test)
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Drop dpkg hooks for the disabled daemon; keep the documented HMAC setup tool.
	rm "${ED}"/usr/share/amdcuid/amdcuid_postinst.sh || die
	rm "${ED}"/usr/share/amdcuid/amdcuid_prerm.sh || die
}

pkg_postinst() {
	if [[ ! -f ${EROOT}/etc/amdcuid/hmac_key.bin ]]; then
		elog "Identifiers derived from a software fingerprint (used where the"
		elog "hardware exposes no serial of its own) are keyed by an HMAC secret"
		elog "that is NOT provisioned automatically -- generating it here would"
		elog "put an untracked file under /etc. To create it, run as root:"
		elog
		elog "    /usr/share/amdcuid/amdcuid_setup_hmac.sh"
		elog
		elog "It writes 32 bytes from openssl rand to /etc/amdcuid/hmac_key.bin."
		elog "Keep that file: the fingerprint-derived IDs change if it does."
	fi
}
