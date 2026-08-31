# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Component Unified Identifier: deterministic hardware IDs for GPUs, CPUs and NICs"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/cuid"
# New package; ::gentoo carries nothing of it. CUID derives a deterministic
# 122-bit identifier for a hardware component from PCIe DSN capabilities,
# SMBIOS/ACPI serials and similar architectural markers, so the same device can
# be referred to consistently across vendors and tools. Vendor-neutral and not
# GPU-specific despite shipping in the ROCm tree, hence sys-apps.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the 10.0
# source ships as the cuid.tar.gz asset on the rocm-systems
# therock-<major.minor> release.
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/cuid.tar.gz -> cuid-${PV}.tar.gz"
S="${WORKDIR}/cuid"

LICENSE="MIT"
# Versioned by the ROCm release rather than upstream's own version, which it
# scrapes out of lib/include/amd_cuid.h (0.x here), matching the rest of the
# stack.
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="examples test"
RESTRICT="!test? ( test )"

# OpenSSL is load-bearing in a way worth stating: upstream does
# find_package(OpenSSL QUIET) and, if it is NOT found, falls back to
# FetchContent-cloning janbar/openssl-cmake at configure time -- which cannot
# work under network-sandbox and would pull in a second, vendored OpenSSL if it
# could. Declaring the dependency is what keeps the system copy in play.
# verified 2026-08-31.
RDEPEND="
	dev-libs/openssl:=
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		# Plain `set(... CACHE STRING ...)` with no FORCE upstream, so -D wins.
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		# Upstream default is OFF and it stays OFF: the daemon ships a
		# systemd unit template plus a postinst script, so wiring it up would
		# need an OpenRC service and an acct-user of its own. The library and
		# the amdcuid CLI are the useful parts. Revisit if anyone wants it.
		-DBUILD_DAEMON=OFF
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTS=$(usex test)
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# amdcuid_postinst.sh / amdcuid_prerm.sh are dpkg lifecycle hooks, not
	# tools: they exist to be run by the .deb's maintainer scripts, and both
	# dispatch to amdcuid_daemon_{postinst,prerm}.sh and ../../bin/amdcuid_daemon
	# -- none of which exist here, since BUILD_DAEMON is off. They would be
	# broken by construction. amdcuid_setup_hmac.sh stays: it is the real
	# provisioning step and is documented in pkg_postinst below.
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
