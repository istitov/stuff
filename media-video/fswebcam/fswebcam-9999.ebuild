# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit git-r3

DESCRIPTION="Neat and simple webcam grabbing app"
HOMEPAGE="https://www.sanslogic.co.uk/fswebcam/
	https://codeberg.org/fsphil/fswebcam"
EGIT_REPO_URI="https://codeberg.org/fsphil/fswebcam.git"

LICENSE="GPL-2"
SLOT="0"

DEPEND="media-libs/gd[truetype,png,jpeg]"
RDEPEND="${DEPEND}"

src_install() {
	# The Makefile installs a man page it gzipped itself; let portage
	# compress docs instead.
	dobin fswebcam
	doman fswebcam.1
	einstalldocs
}
