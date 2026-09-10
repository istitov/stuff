# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="Converts DVI files to SVG"
HOMEPAGE="https://dvisvgm.de/"
SRC_URI="https://github.com/mgieseki/dvisvgm/releases/download/${PV}/${P}.tar.gz"

# Bundled Boost, clipper, and variant code is Boost-1.0; md5 is PD or BSD-1.
LICENSE="GPL-3 Boost-1.0 || ( public-domain BSD-1 )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-arch/brotli-1.0.5:=
	app-text/ghostscript-gpl:=
	dev-libs/kpathsea:=
	>=dev-libs/xxhash-0.8.1
	>=media-gfx/potrace-1.10-r1
	media-libs/freetype:2
	>=media-libs/woff2-1.0.2
	virtual/zlib:=
	virtual/tex-base
"
DEPEND="
	${RDEPEND}
	test? ( >=dev-cpp/gtest-1.11 )
"
BDEPEND="
	app-text/asciidoc
	app-text/xmlto
	dev-libs/libxslt
	virtual/pkgconfig
"

src_configure() {
	# LTO exposes an ODR violation with -fno-semantic-interposition.
	filter-lto

	local myargs=(
		--disable-bundled-libs
		--without-ttfautohint
	)

	econf "${myargs[@]}"
}
