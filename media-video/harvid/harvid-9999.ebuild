# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

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
	media-libs/libpng:0
	virtual/jpeg:0"

RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack
}

MAKEOPTS="-j1"
