# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gimp-luce-plugin/gimp-luce-plugin-2.0.0.ebuild,v 0.1 2013/11/25 20:30:12 brothermechanic Exp $

EAPI="5"

inherit eutils autotools

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