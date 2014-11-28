# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cuda-z/cuda-z-9999.ebuild,v 0.1 2014/11/28 19:11:23 brothermechanic Exp $

EAPI=5

inherit subversion eutils qt4-r2

DESCRIPTION="CUDA Information Utility for nVIDIA chipsets."
HOMEPAGE="http://cuda-z.sourceforge.net/"
ESVN_REPO_URI="svn://svn.code.sf.net/p/cuda-z/code/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="-sm_30 -sm_35"
DEPEND="x11-drivers/nvidia-drivers
	dev-util/nvidia-cuda-toolkit
	dev-qt/qtcore:4
	dev-qt/qtgui:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/trunk"

src_unpack(){
	subversion_fetch
}

src_prepare(){
	epatch "${FILESDIR}"/gentoo-amd64.patch
}

src_configure() {
	if use sm_30; then
	  eqmake4 CONFIG+=sm_30 
	fi
	if use sm_35; then
	  eqmake4 CONFIG+=sm_35
	fi
}

rc_install() {
	dobin bin/${PN}
}
