# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/wayland/weston"

inherit autotools autotools-utils git-2

DESCRIPTION="demos for wayland the (compositing) display server library"
HOMEPAGE="http://wayland.freedesktop.org"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="+poppler +svg +clients +simple-clients
	+compositor-drm +compositor-x11 +compositor-wayland compositor-openwfd"

DEPEND="x11-base/wayland
	>=media-libs/mesa-9999[gles2,egl]
	x11-libs/pixman
	media-libs/libpng
	compositor-drm? (
		>=sys-fs/udev-136
		>=x11-libs/libdrm-2.4.25
		media-libs/mesa[gbm]
	)
	compositor-x11? (
		x11-libs/libxcb
		x11-libs/libX11
	)
	compositor-openwfd? (
		media-libs/owfdrm
		media-libs/mesa[gbm]
	)
	compositor-wayland? (
		media-libs/mesa[wayland]
	)
	clients? (
		media-libs/mesa[wayland]
		dev-libs/glib:2
		media-libs/libjpeg-turbo
		>=x11-libs/cairo-1.11.3[opengl]
		|| ( x11-libs/gdk-pixbuf:2 <x11-libs/gtk+-2.20:2 )
		=x11-libs/libxkbcommon-9999
		poppler? ( app-text/poppler[cairo] )
	)
	simple-clients? ( media-libs/mesa[wayland] )
	svg? ( gnome-base/librsvg )"

RDEPEND="${DEPEND}"

# FIXME: add with-poppler to wayland configure
myeconfargs=(
	# prefix with "wayland-" if not already
	"--program-transform-name='/^weston/!s/^/weston-/'"
	$(use_enable clients)
	$(use_enable simple-clients)
	$(use_enable compositor-drm drm-compositor)
	$(use_enable compositor-x11 x11-compositor)
	$(use_enable compositor-wayland wayland-compositor)
	$(use_enable compositor-openwfd openwfd-compositor)
)

src_prepare()
{
	sed -i -e "/PROGRAMS/s/noinst/bin/" \
		{src,clients}"/Makefile.am" || \
		die "sed {compositor,clients}/Makefile.am failed!"
	eautoreconf
}
