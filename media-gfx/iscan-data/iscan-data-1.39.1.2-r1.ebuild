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

DOCS=( NEWS SUPPORTED-DEVICES KNOWN-PROBLEMS )

src_install() {
	default

	# Upstream's make-policy-file copies an Epson rule out of sane-backends'
	# *sane.rules. sane-backends now installs 65-sane-backends.rules and keeps
	# its device list in the udev hwdb, so the helper finds no file to read,
	# and pointed at the new one it finds no Epson rule to copy. That hwdb
	# already covers most epkowa IDs; a static file covers the rest.
	# verified 2026-09-26 with sane-backends-1.3.1-r2
	use udev && udev_dorules "${FILESDIR}"/60-iscan.rules
}

pkg_postinst() {
	use udev && udev_reload
}

pkg_postrm() {
	use udev && udev_reload
}
