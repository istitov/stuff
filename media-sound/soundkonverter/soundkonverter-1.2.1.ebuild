# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/soundkonverter/soundkonverter-1.2.0.ebuild,v 1.1 2011/11/15 23:38:09 dilfridge Exp $

EAPI=4

inherit kde4-base

DESCRIPTION="Frontend to various audio converters"
HOMEPAGE="http://www.kde-apps.org/content/show.php/soundKonverter?content=29024"
SRC_URI="https://gitorious.org/soundkonverter/soundkonverter/blobs/raw/6a527f4ea559795b31a93477217c107f40326053/release/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="
	$(add_kdebase_dep libkcddb)
	$(add_kdebase_dep libkcompactdisc)
	media-libs/taglib
	media-sound/cdparanoia
"
RDEPEND="${DEPEND}"
