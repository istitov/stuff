# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="OpenGL (ES) 2.0 benchmark for X11, Wayland and DRM"
HOMEPAGE="https://github.com/glmark2/glmark2"
SRC_URI="https://github.com/glmark2/glmark2/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

# HPND: the SGI notice on the "ideas" scene (COPYING.SGI)
LICENSE="GPL-3+ HPND"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+X drm gles2 +opengl wayland"
REQUIRED_USE="
	|| ( X drm wayland )
	|| ( gles2 opengl )
"

# libGL, libEGL and libGLESv2 are dlopen()ed through the bundled glad
# loader, so libglvnd is a runtime-only dependency.
RDEPEND="
	media-libs/libglvnd[X?]
	media-libs/libjpeg-turbo:=
	media-libs/libpng:=
	X? ( x11-libs/libX11 )
	drm? (
		media-libs/mesa[opengl]
		virtual/libudev:=
		x11-libs/libdrm
	)
	wayland? ( dev-libs/wayland )
"
DEPEND="
	${RDEPEND}
	X? ( x11-base/xorg-proto )
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

PATCHES=(
	"${FILESDIR}"/${P}-gbm-egl-platform.patch
)

src_prepare() {
	default
	# copies for the waf/Android builds; meson uses the system libraries
	rm -r src/libjpeg-turbo src/libpng src/zlib || die
}

src_configure() {
	local flavors=()
	if use X; then
		use opengl && flavors+=( x11-gl x11-gl-egl )
		use gles2 && flavors+=( x11-glesv2 )
	fi
	if use drm; then
		use opengl && flavors+=( drm-gl gbm-gl )
		use gles2 && flavors+=( drm-glesv2 gbm-glesv2 )
	fi
	if use wayland; then
		use opengl && flavors+=( wayland-gl )
		use gles2 && flavors+=( wayland-glesv2 )
	fi

	local emesonargs=(
		-Dflavors="$(IFS=,; echo "${flavors[*]}")"
	)
	meson_src_configure
}
