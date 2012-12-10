# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils git-2

DESCRIPTION="OpenImageIO is a library for reading and writing images."
HOMEPAGE="https://sites.google.com/site/openimageio/"
EGIT_REPO_URI="git://github.com/OpenImageIO/oiio.git"
EGIT_BRANCH="master"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE="+viewer"

DEPEND="dev-libs/boost
		media-libs/ilmbase
		virtual/jpeg
		media-libs/libpng
		media-libs/openexr
		media-libs/tiff
		sys-libs/zlib
		viewer? ( media-libs/glew
				 x11-libs/qt-opengl
		)"

RDEPEND="${DEPEND}"

src_compile() {
	if use viewer; then
		emake || die
	else
		emake USE_OPENGL=0 || die
	fi
}

src_install() {
	dobin dist/linux64/bin/*
	dodoc dist/linux64/doc/*
	insinto /usr/include/
	doins -r dist/linux64/include/*
	dolib dist/linux64/lib/*
}
