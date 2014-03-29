# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/bibledit/bibledit-9999.ebuild,v 1.0 2014/03/28 18:20:23 brothermechanic Exp $

EAPI="5"

DESCRIPTION="The software for translating a Bible"
HOMEPAGE="https://sites.google.com/site/bibledit/"
SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND="app-editors/bibledit-bibletime
	app-editors/bibledit-bibleworks
	app-editors/bibledit-gtk
	app-editors/bibledit-onlinebible
	app-editors/bibledit-paratext
	app-editors/bibledit-xiphos"

RDEPEND="${DEPEND}"
