# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/megatools/megatools-1.9.91.ebuild,v 1 2013/05/03 12:55:38 megabaks Exp $

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
RDEPEND=""
