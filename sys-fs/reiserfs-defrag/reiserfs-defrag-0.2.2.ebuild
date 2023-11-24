# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake
DESCRIPTION="Small defragmentation tool for reiserfs"
HOMEPAGE="https://github.com/i-rinat/reiserfs-defrag"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/i-rinat/reiserfs-defrag.git"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/i-rinat/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"

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
