# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit cmake-utils git-2
DESCRIPTION="Small defragmentation tool for reiserfs"
HOMEPAGE="https://github.com/i-rinat/reiserfs-defrag"
EGIT_REPO_URI="git://github.com/i-rinat/reiserfs-defrag.git"

LICENSE="as-is"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
src_compile() {
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr "${S}"
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
