# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit git-2
DESCRIPTION="Silly userspace utility to measure desktop interactivity under different loads."
HOMEPAGE="http://github.com/pfactum/kernelat"
EGIT_REPO_URI="https://github.com/pfactum/kernelat.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"
src_install() {
	dosbin kernelat-spawner/kernelat-spawner || die "Install failed"
	dosbin kernelat-spawner/kernelat.sh || die "Install failed"
	dodoc README.md || die "Install failed"
}
