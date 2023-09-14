# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake git-r3
DESCRIPTION="Small defragmentation tool for reiserfs"
HOMEPAGE="https://github.com/i-rinat/reiserfs-defrag"
EGIT_REPO_URI="git://github.com/i-rinat/reiserfs-defrag.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
src_compile() {
	cmake -DCMAKE_INSTALL_PREFIX=/usr "${S}"
	emake || die "emake failed"
}
src_install() {
dosbin reiserfs-defrag || die "Install failed"
dodoc README.md || die "Install failed"
dodoc doc/inside.md || die "Install failed"
dodoc ChangeLog || die "Install failed"
doman doc/reiserfs-defrag.8 || die "Install failed"
}
