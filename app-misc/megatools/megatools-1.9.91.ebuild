# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="Collection of programs for accessing Mega service from a command line."
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
