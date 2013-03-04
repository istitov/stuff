# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/osl/osl-9999.ebuild,v 1.1 2013/03/04 16:11:23 brothermechanic Exp $

EAPI=4

inherit git-2 eutils

DESCRIPTION="Open Shading Language"
HOMEPAGE="http://code.google.com/p/openshadinglanguage/"
EGIT_REPO_URI="https://github.com/DingTo/OpenShadingLanguage.git"
EGIT_BRANCH="blender-fixes"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	>=dev-libs/boost-1.52.0
	media-libs/openimageio[pugixml]
	sys-devel/clang
	sys-devel/bison
	sys-devel/flex
	media-libs/ilmbase"

RDEPEND=""

src_configure() {
	if use test ; then
	mycmakeargs=( -DBUILD_TESTING=ON  )
	else
	mycmakeargs=( -DBUILD_TESTING=OFF )
	fi

	epatch "${FILESDIR}"/gabornoise-306.patch || die "Patch failed"
	cmake-utils_src_configure
}

src_install() {
	dobin dist/linux64/bin/*
	dodoc dist/linux64/doc/*
	insinto /usr/include/
	doins -r dist/linux64/include/*
	dolib dist/linux64/lib/*
	insinto /usr/include/OSL/shaders
	doins -r dist/linux64/shaders/*
	cmake-utils_src_install
}
