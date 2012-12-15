# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit cmake-utils
DESCRIPTION="Small defragmentation tool for reiserfs"
HOMEPAGE="https://github.com/i-rinat/reiserfs-defrag"
MY_P=v${PV}
SRC_URI="https://github.com/i-rinat/reiserfs-defrag/archive/${MY_P}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
#S=${WORKDIR}/${MY_P}
src_compile() {
	cmake -DCMAKE_INSTALL_PREFIX=/usr "${S}"
	emake || die "emake failed"
}
src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
src_install() {
	dosbin rfsd || die "Install failed"
	dodoc README.md || die "Install failed"
	dodoc ChangeLog || die "Install failed"
}
