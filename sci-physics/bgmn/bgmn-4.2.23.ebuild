# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source XRD and Rietveld refinement engine"
# www.bgmn.de serves only http (no TLS at all on :443 as of 2026-05-09);
# leave that one as http to silence pkgcheck SSLCertificateError without
# pretending it has https.
HOMEPAGE="https://www.profex-xrd.org http://www.bgmn.de/"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2022/10/${P}-x86_64.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# Pre-built upstream binaries; do not strip and do not assume any
# external libraries beyond glibc. ldd shows only libpthread/libm/libc.
RESTRICT="strip mirror"

QA_PREBUILT="opt/bgmn/*"

src_install() {
	# bgmn binaries look up atomic-form-factor / wavelength /
	# space-group / error-message / template data through the EFLECH
	# environment variable; without it, every binary aborts with
	# "*** undefined environment EFLECH". Install the whole upstream
	# tarball verbatim under /opt/bgmn/ (FHS-style for vendor
	# pre-built blobs) and ship /usr/bin/ wrappers that point EFLECH
	# at it before exec'ing the real binary.
	insinto /opt/${PN}
	# 4.2.23 ships no *.xml (older releases did); the stale glob expands
	# to a literal '*.xml' and aborts doins. Drop it.
	doins *.dat *.lam *.mdr *.ano *.cfg err.msg \
		spacegrp index output plot1 weight.mol \
		gertest lamtest verzerr

	exeinto /opt/${PN}
	local bins=( bgmn makegeq geomet teil eflech )
	doexe "${bins[@]}"

	local b
	for b in "${bins[@]}"; do
		cat > "${T}/${b}" <<-EOF || die
			#!/bin/sh
			export EFLECH="\${EFLECH:-/opt/${PN}}"
			exec /opt/${PN}/${b} "\$@"
		EOF
		dobin "${T}/${b}"
	done
}
