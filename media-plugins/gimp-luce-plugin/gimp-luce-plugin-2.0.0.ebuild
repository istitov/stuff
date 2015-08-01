# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: brothermechanic $

EAPI="5"

inherit eutils

DESCRIPTION="Luce for GIMP is a port of Amico Perry's Luce Photoshop plug-in."
HOMEPAGE="http://registry.gimp.org/node/28271"
SRC_URI="http://reddog.s35.xrea.com/software/luce-2.0.0.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="media-gfx/gimp"
RDEPEND=""

S="${WORKDIR}/luce-2.0.0/"
