# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 eutils

DESCRIPTION="Sift detector"
HOMEPAGE="http://www.vlfeat.org/index.html"
EGIT_REPO_URI="https://github.com/vlfeat/vlfeat.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

#TODO check for all deps
DEPEND="
	virtual/lapack"

RDEPEND="${DEPEND}"

src_prepare() {
	rm -r bin/glnxa64
}

src_configure() {
	export ARCH=glnxa64
}

src_install() {
	rm -r bin/glnxa64/*.d bin/glnxa64/objs|| die
	dolib bin/glnxa64/libvl.so
	rm bin/glnxa64/libvl.so
	dobin bin/glnxa64/*
}
