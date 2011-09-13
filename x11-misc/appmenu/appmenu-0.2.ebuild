# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:Exp $

EAPI="3"
SLOT="0"
DESCRIPTION="Metapackage for appmenu"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE="gtk qt4"
DEPEND="gtk? ( >=x11-misc/appmenu-gtk-0.2 )
		qt4?  ( >=x11-misc/appmenu-qt-0.2 )"
