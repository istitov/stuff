# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit kde4-base

MY_PN="iHateTheCashew"

DESCRIPTION="KDE4 plasmoid. Removes the \"hand\" in upper right corner of the screen"
HOMEPAGE="https://github.com/gustavosbarreto/plasma-ihatethecashew"
SRC_URI="https://github.com/gustavosbarreto/plasma-ihatethecashew/archive/master.zip"

LICENSE="GPL-3"
KEYWORDS=""
SLOT="0"
IUSE="debug"

RDEPEND="
	$(add_kdebase_dep plasma-workspace)
"

S="${WORKDIR}/${MY_PN}"

#src_prepare() {
#	epatch "${FILESDIR}"/4.6-support.patch
#}
