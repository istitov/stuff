# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/harvid/harvid-9999.ebuild,v 0.1 2013/10/29 19:16:01 brothermechanic Exp $

EAPI=5

inherit git-2 eutils

DESCRIPTION="http ardour video daemon"
HOMEPAGE="http://x42.github.com/harvid/"
EGIT_REPO_URI="https://github.com/x42/harvid.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-video/ffmpeg
	media-libs/libpng
	virtual/jpeg"

RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack
}

MAKEOPTS="-j1"
