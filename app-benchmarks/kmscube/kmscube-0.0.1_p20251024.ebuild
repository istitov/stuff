# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

# upstream has no tags; the version is meson.build's
COMMIT="f60e50e887d3c49e91ac9b06d8199b36152632fa"

DESCRIPTION="Spinning cube demo and test for KMS/GBM/EGL/GLES"
HOMEPAGE="https://gitlab.freedesktop.org/mesa/kmscube"
SRC_URI="https://gitlab.freedesktop.org/mesa/kmscube/-/archive/${COMMIT}/kmscube-${COMMIT}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/kmscube-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gstreamer"

RDEPEND="
	media-libs/libglvnd
	media-libs/libpng:=
	media-libs/mesa[opengl]
	>=x11-libs/libdrm-2.4.71
	gstreamer? (
		dev-libs/glib:2
		>=media-libs/gstreamer-1.22.0:1.0
		>=media-libs/gst-plugins-base-1.22.0:1.0[egl,gles2]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local emesonargs=(
		$(meson_feature gstreamer)
	)
	meson_src_configure
}
