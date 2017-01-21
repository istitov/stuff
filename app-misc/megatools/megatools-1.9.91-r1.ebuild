# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Collection of programs for accessing Mega service from a command line of your desktop or server."
HOMEPAGE="http://megatools.megous.com/"
SRC_URI="http://megatools.megous.com/builds/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/glib:2
		sys-fs/fuse
		net-misc/curl
		dev-libs/openssl"
RDEPEND="net-libs/glib-networking"
