# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="neat and simple webcam grabbing app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/"
SRC_URI="http://www.sanslogic.co.uk/fswebcam/files/${PN}-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
IUSE=""

DEPEND="media-libs/gd"
RDEPEND="${DEPEND}"
