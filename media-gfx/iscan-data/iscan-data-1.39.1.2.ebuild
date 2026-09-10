# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit udev

DESCRIPTION="Image Scan! for Linux data files"
# Epson's portal returns HTTP 403; use its archived landing page.
# verified 2026-05-10
HOMEPAGE="https://web.archive.org/web/20191230072555/http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
# Upstream and Gentoo mirrors lack the tarball; Wayback serves the byte-identical
# 2019 snapshot, with `if_` requesting raw bytes. verified 2026-05-02
SRC_URI="https://web.archive.org/web/20191023164257if_/http://support.epson.net/linux/src/scanner/iscan/${PN}_$(ver_rs 3 -).tar.gz"
S="${WORKDIR}/${PN}-$(ver_cut 1-3)"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="udev"

DEPEND="
	udev? (
		dev-libs/libxslt
		media-gfx/sane-backends
	)"

DOCS=( NEWS SUPPORTED-DEVICES KNOWN-PROBLEMS )

src_install() {
	ewarn "Some profiles automatically enable udev which will cause install"
	ewarn "to fail if media-gfx/sane-backends is not already installed."
	default

	if use udev; then
		local rulesdir=$(get_udevdir)/rules.d
		dodir ${rulesdir}
		"${D}/usr/$(get_libdir)/iscan-data/make-policy-file" \
			--force --mode udev \
			-d "${D}/usr/share/iscan-data/epkowa.desc" \
			-o "${D}${rulesdir}/99-iscan.rules" || die
	fi
}
