# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit bzr gnome2 eutils flag-o-matic

SRC_URI=""
EBZR_REPO_URI="lp:inkscape"
EBZR_PROJECT="inkscape"

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"

SLOT="0"
LICENSE="GPL-2 LGPL-2.1"
KEYWORDS=""
IUSE="dia gs gnome inkjar dbus lcms nls poppler postscript python perl wmf wpg"
RESTRICT="test"

COMMON_DEPEND="
	dev-cpp/glibmm
	dev-cpp/gtkmm:2.4
	>=dev-libs/boehm-gc-6.4
	>=dev-libs/glib-2.6.5
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml
	|| ( media-gfx/imagemagick[cxx] media-gfx/graphicsmagick[cxx,symlink] )
	media-libs/fontconfig
	media-libs/freetype:2
	>=media-libs/libpng-1.5
	app-text/libwpd:0.9
	wpg? ( app-text/libwpg:0.2 )
	sci-libs/gsl
	x11-libs/libXft
	x11-libs/gtk+:2
	>=x11-libs/pango-1.4.0
	|| ( dev-lang/python[xml] dev-python/pyxml )
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	lcms? ( media-libs/lcms:0 )"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="
	${COMMON_DEPEND}
	dev-python/numpy
	media-gfx/uniconvertor
	postscript? ( media-gfx/pstoedit )
	dia? ( app-office/dia )
	gs? ( app-text/ghostscript-gpl )"
DEPEND="${COMMON_DEPEND}
	dev-libs/boost
	sys-devel/gettext
	dev-util/pkgconfig
	x11-libs/libX11
	>=dev-util/intltool-0.29"

src_unpack() {
	bzr_src_unpack
}
src_configure(){
	sh autogen.sh || die "autogen"
	econf \
	$(use_with perl)\
	$(use_with python)\
	$(use_enable poppler poppler-cairo)\
	$(use_with gnome gnome-vfs)\
	$(use_with inkjar)\
	$(use_enable wpg)\
	$(use_enable dbus dbusapi)\
	$(use_enable lcms)\
	$(use_enable nls)\

	DOCS="AUTHORS ChangeLog NEWS README*"

	#./configure
	# aliasing unsafe wrt #310393
	#append-flags -fno-strict-aliasing
	#gnome2_src_configure
}

pkg_postinst() {
	elog "local configurations (also includes extensions) are moved from"
	elog "\${HOME}/.inkscape to \${HOME}/.config/inkscape within"
	elog ">=media-gfx/inkscape-0.48"
}
