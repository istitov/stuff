# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit meson python-any-r1

DESCRIPTION="Extensible Vulkan benchmarking suite"
HOMEPAGE="https://github.com/vkmark/vkmark"
SRC_URI="https://github.com/vkmark/vkmark/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="X drm test wayland"
RESTRICT="!test? ( test )"

RDEPEND="
	media-libs/assimp:=
	media-libs/vulkan-loader
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
	)
	drm? (
		media-libs/mesa[opengl]
		x11-libs/libdrm
	)
	wayland? ( dev-libs/wayland )
"
# vk.xml from vulkan-headers feeds the format map generator
DEPEND="
	${RDEPEND}
	dev-util/vulkan-headers
	media-libs/glm
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

src_configure() {
	local emesonargs=(
		-Dxcb=$(usex X true false)
		-Dkms=$(usex drm true false)
		-Dwayland=$(usex wayland true false)
	)
	meson_src_configure
}
