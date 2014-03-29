# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/bibledit-paratext/bibledit-paratext-9999.ebuild,v 1.0 2014/03/28 16:50:23 brothermechanic Exp $

EAPI="5"

inherit eutils autotools git-2

DESCRIPTION="The software for translating a Bible"
HOMEPAGE="https://sites.google.com/site/bibledit/"
EGIT_REPO_URI="git://git.sv.gnu.org/bibledit.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="dev-vcs/rcs
	=x11-libs/gtksourceview-2*
	net-libs/webkit-gtk"

RDEPEND="${DEPEND}"

src_prepare() {
	mv paratext/* .
	chmod +x configure || die
	eautoreconf
}
