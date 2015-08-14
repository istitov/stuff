# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit autotools

DESCRIPTION="Tools for Flash-Friendly File System (F2FS)"
HOMEPAGE="http://sourceforge.net/projects/f2fs-tools/ http://git.kernel.org/?p=linux/kernel/git/jaegeuk/f2fs-tools.git;a=summary"
SRC_URI="http://git.kernel.org/cgit/linux/kernel/git/jaegeuk/${PN}.git/snapshot/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm ppc ppc64 x86"
IUSE=""

src_prepare () {
	eautoreconf
}
