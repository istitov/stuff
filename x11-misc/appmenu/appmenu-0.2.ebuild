# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:Exp $

EAPI="3"
SLOT="0"
HOMEPAGE="none"
DESCRIPTION="Metapackage for appmenu"
KEYWORDS="-alpha ~amd64 -ppc64 -sparc ~x86"
IUSE="gtk qt4 kde gnome"
DEPEND="gtk? ( x11-misc/appmenu-gtk )
		qt4?  ( x11-misc/appmenu-qt )
		kde? ( kde-misc/plasma-widget-menubar )
		gnome? ( x11-misc/indicator-appmenu )"
