# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Mozilla's Universal Charset Detector C/C++ API"
HOMEPAGE="https://github.com/Joungkyun/libchardet"
SRC_URI="https://github.com/Joungkyun/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-1.1 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
