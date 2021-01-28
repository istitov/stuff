# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils

DESCRIPTION="Visualizes the fragmentation status of ext2/3 filesystems"
HOMEPAGE="http://davl.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-fs/e2fsprogs
	x11-libs/gtk+:2"
RDEPEND="${DEPEND}"

src_compile() {
	emake WITH_DRV=1 || die "emake failed"
	linux-mod_src_compile
}

src_install() {
	dobin src/cdavl/cdavl src/gdavl/gdavl
	dodoc README
	doman doc/*.8
	linux-mod_src_install
	insinto /etc/modprobe.d
	insinto /etc/init.d
	newinitd "${FILESDIR}"/davl davl
	chmod 644 src/drv/davl_liveinfo.ko
	insinto /lib/modules/$(uname -r)/kernel/drivers/davl
	doins src/drv/davl_liveinfo.ko
}
