# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="Library to manipulate EFI variables"
HOMEPAGE="https://github.com/vathpela/efivar"
SRC_URI="https://github.com/vathpela/${PN}/archive/${PN}-${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/popt"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${P}"
src_compile() {
	OPT_FLAGS="${CFLAGS}"
	unset CFLAGS
	emake \
		OPT_FLAGS="${OPT_FLAGS}" \
		libdir=$(get_libdir) \
		|| die "emake failed"
}
