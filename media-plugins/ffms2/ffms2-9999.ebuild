# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/ffms2/ffms2-9999.ebuild,v 1.1 2013/12/24 16:11:23 brothermechanic Exp $

EAPI=5

inherit git-2 eutils

DESCRIPTION="A ffmpeg Avisynth plugin"
HOMEPAGE="https://code.google.com/p/ffmpegsource/"
EGIT_REPO_URI="https://github.com/FFMS/ffms2.git"
EGIT_BRANCH="master"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="virtual/ffmpeg"

RDEPEND=""

src_configure() {
	econf --enable-shared --disable-static
}
