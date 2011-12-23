# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/wayland/wayland-demos"
EGIT_BOOTSTRAP="eautoreconf"

inherit autotools autotools-utils git-2

DESCRIPTION="demos for wayland the (compositing) display server library"
HOMEPAGE="http://wayland.freedesktop.org"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+poppler +svg +clients
	+compositor-drm +compositor-x11 +compositor-wayland compositor-openwfd tablet"

DEPEND="x11-base/wayland
	>=media-libs/mesa-9999[gles2,wayland]
	x11-libs/pixman
	=x11-libs/libxkbcommon-9999
	media-libs/libpng
	media-libs/libjpeg-turbo
	compositor-drm? (
		>=sys-fs/udev-136
		>=x11-libs/libdrm-2.4.25
	)
	compositor-x11? (
		x11-libs/libxcb
		x11-libs/libX11
	)
	compositor-openwfd? (
		media-libs/owfdrm
	)
	clients? (
		dev-libs/glib:2
		>=x11-libs/cairo-1.10.0[opengl]
		|| ( x11-libs/gdk-pixbuf:2 <x11-libs/gtk+-2.20:2 )
		poppler? ( app-text/poppler[cairo] )
	)
	svg? ( gnome-base/librsvg )"

RDEPEND="${DEPEND}"

# FIXME: add with-poppler to wayland configure
myeconfargs=(
	$(use_enable clients)
	$(use_enable compositor-drm drm-compositor)
	$(use_enable compositor-x11 x11-compositor)
	$(use_enable compositor-wayland wayland-compositor)
	$(use_enable compositor-openwfd openwfd-compositor)
	$(use_enable tablet tablet-shell)
)

src_prepare()
{
	sed -i -e "/PROGRAMS/s/noinst/bin/" \
		{compositor,clients}"/Makefile.am" || \
		die "sed {compositor,clients}/Makefile.am failed!"
}

pkg_postinst()
{
	einfo "To run the wayland exmaple compositor as x11 client execute:"
	einfo "   DISPLAY=:0 EGL_PLATFORM=x11 EGL_DRIVER=egl_dri2 wayland-compositor"
	einfo
	einfo "Start the wayland clients with EGL_PLATFORM set to wayland:"
	einfo "   EGL_PLATFORM=wayland terminal"
	einfo
}
