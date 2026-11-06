# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit flag-o-matic meson-multilib python-any-r1 xdg-utils

DESCRIPTION="An OpenType text shaping engine"
HOMEPAGE="https://harfbuzz.github.io/"

if [[ ${PV} == 9999 ]] ; then
	EGIT_REPO_URI="https://github.com/harfbuzz/harfbuzz.git"
	inherit git-r3
else
	SRC_URI="https://github.com/harfbuzz/harfbuzz/releases/download/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="Old-MIT ISC icu"
# 0.9.18 introduced the harfbuzz-icu split; bug #472416
# 3.0.0 dropped some unstable APIs; bug #813705
# 6.0.0 changed libharfbuzz-subset.so ABI
SLOT="0/6.0.0"

IUSE="+cairo debug doc experimental +glib +graphite icu +introspection +png test +truetype"
RESTRICT="!test? ( test )"
REQUIRED_USE="introspection? ( glib )"

# The raster library decodes PNG colour glyphs with libpng, and the vector
# library compresses its PDF output with zlib; both are meson "auto" features
# and were linked automagically. verified 2026-11-06
RDEPEND="
	virtual/zlib:=[${MULTILIB_USEDEP}]
	cairo? ( x11-libs/cairo:=[${MULTILIB_USEDEP}] )
	glib? ( >=dev-libs/glib-2.38:2[${MULTILIB_USEDEP}] )
	graphite? ( >=media-gfx/graphite2-1.2.1:=[${MULTILIB_USEDEP}] )
	icu? ( >=dev-libs/icu-51.2-r1:=[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.82.0-r2:= )
	png? ( media-libs/libpng:=[${MULTILIB_USEDEP}] )
	truetype? ( >=media-libs/freetype-2.5.0.1:2=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	sys-apps/help2man
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
	introspection? ( dev-util/glib-utils )
"

src_prepare() {
	default

	xdg_environment_reset

	# bug #790359
	filter-flags -fexceptions -fthreadsafe-statics

	if ! use debug ; then
		append-cppflags -DHB_NDEBUG
	fi
}

multilib_src_configure() {
	# harfbuzz-gobject only used for introspection, bug #535852
	local emesonargs=(
		-Dcoretext=disabled
		-Dchafa=disabled
		-Dfontations=disabled
		-Dwasm=disabled

		# The raster, vector, GPU and subset libraries are stable API since
		# 15.0.0; media-libs/opencv 5.1 draws text through hb-raster. The
		# hb-gpu demo would otherwise pick up GLEW, GLFW and GL automagically.
		-Draster=enabled
		-Dvector=enabled
		-Dgpu=enabled
		-Dsubset=enabled
		-Dgpu_demo=disabled
		-Dzlib=enabled

		$(meson_feature cairo)
		$(meson_feature glib)
		$(meson_feature graphite graphite2)
		$(meson_feature icu)
		$(meson_feature introspection gobject)
		$(meson_feature png)
		$(meson_feature test tests)
		$(meson_feature truetype freetype)

		$(meson_native_use_feature doc docs)
		$(meson_native_use_feature introspection)
		# Breaks building tests..
		#$(meson_native_use_feature utilities)

		$(meson_use experimental experimental_api)
	)

	meson_src_configure
}

multilib_src_test() {
	# harfbuzz:src / check-static-inits times out on hppa
	meson_src_test --timeout-multiplier 5
}
