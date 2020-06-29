# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake git-r3
DESCRIPTION="Silly userspace utility to measure desktop interactivity under different loads."
HOMEPAGE="https://github.com/pfactum/kernelat"
EGIT_REPO_URI="https://github.com/pfactum/kernelat.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/openssl:0
dev-libs/libpww
net-libs/zeromq"
RDEPEND="${DEPEND}"
src_compile() {
	cmake -DCMAKE_INSTALL_PREFIX=/usr "${S}"
	emake || die "emake failed"
}
src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

src_install() {
	dosbin kernelat-child/kernelat-child || die "Install failed"
	dosbin kernelat-spawner/kernelat-spawner || die "Install failed"
	dosbin kernelat-tester/kernelat-tester.sh || die "Install failed"
	dodoc README.md || die "Install failed"
}
