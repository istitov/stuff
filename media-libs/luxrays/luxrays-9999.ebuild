# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python3_4 )

inherit cmake-utils flag-o-matic mercurial python-single-r1

DESCRIPTION="Library to accelerate the ray intersection process by using GPUs."
HOMEPAGE="http://www.luxrender.net"
EHG_REPO_URI="http://src.luxrender.net/luxrays"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+blender debug"

DEPEND=">=dev-libs/boost-1.43
	media-libs/freeimage
	virtual/opencl
	virtual/opengl"
	
src_prepare() {
	python-single-r1_pkg_setup
	epatch "${FILESDIR}/without-samples.patch"
	epatch_user
}

src_configure() {
	append-flags "-fPIC"
	use debug && append-flags -ggdb

	mycmakeargs=( -Wno-dev )
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make
}

src_install() {
	dodoc ${S}/AUTHORS.txt

	insinto /usr/include
	doins -r ${S}/include/*

	dolib.a ${BUILD_DIR}/lib/*
	
	if use blender; then
		if v="/usr/share/blender/*";then
		    insinto $v/scripts/addons/luxrender/
		    doins "${CMAKE_BUILD_DIR}"/lib/*.so || die "Couldn't install Pylux"
		fi
	fi
}
