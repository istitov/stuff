# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

inherit eutils

DESCRIPTION="MPRIS-plugin for deadbeef"
HOMEPAGE="https://github.com/kernelhcy/DeaDBeeF-MPRIS-plugin"
SRC_URI="http://${PN}.googlecode.com/files/${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef"

RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"

S="${WORKDIR}/deadbeef-${PV}"

