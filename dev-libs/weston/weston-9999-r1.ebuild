# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://anongit.freedesktop.org/git/wayland/${PN}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit autotools toolchain-funcs $GIT_ECLASS

DESCRIPTION="Wayland reference compositor"
HOMEPAGE="http://wayland.freedesktop.org/"

if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="http://wayland.freedesktop.org/releases/${P}.tar.xz"
fi

LICENSE="CCPL-Attribution-ShareAlike-3.0 MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+clients +drm +simple-clients static-libs +tablet +wayland-compositor +x11"

RDEPEND="dev-libs/wayland
	gnome-base/librsvg
	>=media-libs/mesa-7.10[egl,gles2]
	x11-libs/pixman
	x11? ( x11-libs/libxcb x11-libs/libX11 )
	drm? ( >=sys-fs/udev-136 >=x11-libs/libdrm-2.4.23 media-libs/mesa[gbm] )
	clients? ( >=x11-libs/cairo-1.10.0 x11-libs/gdk-pixbuf dev-libs/glib:2
			    media-libs/libpng app-text/poppler )"
DEPEND="${RDEPEND}"

src_prepare() {
	if [[ ${PV} = 9999* ]]; then
		eautoreconf
	fi
}

src_configure() {
	econf --disable-setuid-install
		  $(use_enable static-libs static) \
		  $(use_enable drm drm-compositor) \
		  $(use_enable wayland-compositor) \
		  $(use_enable x11 x11-compositor) \
		  $(use_enable tablet tablet-shell) \
		  $(use_enable clients) \
		  $(use_enable simple-clients)
}
