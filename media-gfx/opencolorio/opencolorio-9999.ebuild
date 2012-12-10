# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/opencolorio/opencolorio-9999.ebuild,v 1.1 2012/12/06 20:45:34 brothermechanic Exp $

EAPI=4

PYTHON_DEPEND="python? 2"

EGIT_REPO_URI="git://github.com/imageworks/OpenColorIO"
EGIT_BRANCH="master"

inherit cmake-utils git-2 python

DESCRIPTION="A color management framework for visual effects and animation"
HOMEPAGE="http://opencolorio.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc opengl python sse2 test"

RDEPEND="opengl? (
		media-libs/lcms:2
		media-libs/openimageio
		media-libs/glew
		media-libs/freeglut
		virtual/opengl
		)
	dev-cpp/yaml-cpp
	dev-libs/tinyxml
	"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx )
	"

# Documentation building requires Python bindings building
REQUIRED_USE="doc? ( python )"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/"${PN}"-use-system-libs.patch
}

src_configure() {
	# Missing features:
	# - Truelight and Nuke are not in portage for now, so their support are disabled
	# - Java bindings was not tested, so disabled
	# - Documentation PDF does not build properly ("automagic dependency on pdflatex")
	# Notes:
	# - OpenImageIO is required for building ociodisplay and ocioconvert (USE opengl)
	# - OpenGL, GLUT and GLEW is required for building ociodisplay (USE opengl)
	local mycmakeargs=(
		-DOCIO_BUILD_JNIGLUE=OFF
		-DOCIO_BUILD_NUKE=OFF
		-DOCIO_BUILD_SHARED=ON
		-DOCIO_BUILD_STATIC=OFF
		-DOCIO_STATIC_JNIGLUE=OFF
		-DOCIO_BUILD_TRUELIGHT=OFF
		$(cmake-utils_use doc OCIO_BUILD_DOCS)
		$(cmake-utils_use opengl OCIO_BUILD_APPS)
		$(cmake-utils_use python OCIO_BUILD_PYGLUE)
		$(cmake-utils_use sse2 OCIO_USE_SSE)
		$(cmake-utils_use test OCIO_BUILD_TESTS)
	)
	cmake-utils_src_configure
}
