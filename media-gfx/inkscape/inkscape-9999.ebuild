# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=4
inherit bzr gnome2 eutils flag-o-matic

SRC_URI=""
EBZR_REPO_URI="lp:inkscape"
EBZR_PROJECT="inkscape"

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"

SLOT="0"
LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~x86"
IUSE="dia gs gnome inkjar lcms mmx nls postscript spell wmf wpg"
RESTRICT="test"

COMMON_DEPEND="
   dev-cpp/glibmm
   >=dev-cpp/gtkmm-2.10.0
   >=dev-libs/boehm-gc-6.4
   >=dev-libs/glib-2.6.5
   >=dev-libs/libsigc++-2.0.12
   >=dev-libs/libxml2-2.6.20
   >=dev-libs/libxslt-1.0.15
   dev-libs/popt
   dev-python/lxml
   media-gfx/imagemagick[cxx] || ( media-gfx/graphicsmagick[cxx,symlink] )
   media-libs/fontconfig
   media-libs/freetype:2
   >=media-libs/libpng-1.5
   app-text/libwpd:0.9
   app-text/libwpg:0.2
   sci-libs/gsl
   x11-libs/libXft
   >=x11-libs/gtk+-2.10.7
   >=x11-libs/pango-1.4.0
   || ( dev-lang/python[xml] dev-python/pyxml )
   gnome? ( >=gnome-base/gnome-vfs-2.0 )
   lcms? ( media-libs/lcms:0 )
   spell? (
      app-text/aspell
      app-text/gtkspell
   )"

# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="
   ${COMMON_DEPEND}
   dev-python/numpy
   media-gfx/uniconvertor
   dia? ( app-office/dia )
   gs? ( app-text/ghostscript-gpl )
   wmf? ( media-libs/libwmf )"

DEPEND="${COMMON_DEPEND}
   dev-libs/boost
   sys-devel/gettext
   dev-util/pkgconfig
   x11-libs/libX11
   >=dev-util/intltool-0.29"

#S=${WORKDIR}/${PN}

pkg_setup() {
	G2CONF="${G2CONF} --without-perl"
	G2CONF="${G2CONF} --enable-poppler-cairo"
	G2CONF="${G2CONF} --with-xft"
	G2CONF="${G2CONF} $(use_with gnome gnome-vfs)"
	G2CONF="${G2CONF} $(use_with inkjar)"
	G2CONF="${G2CONF} $(use_enable lcms)"
	G2CONF="${G2CONF} $(use_enable nls)"
	G2CONF="${G2CONF} $(use_with spell aspell)"
	G2CONF="${G2CONF} $(use_with spell gtkspell)"
	G2CONF="${G2CONF} $(use_enable mmx)"
	DOCS="AUTHORS ChangeLog NEWS README*"
}

src_unpack() {
	bzr_src_unpack
}
src_configure(){
	sh autogen.sh || die "autogen"
	./configure
	# aliasing unsafe wrt #310393
	#append-flags -fno-strict-aliasing
	#gnome2_src_configure
}

pkg_postinst() {
	elog "local configurations (also includes extensions) are moved from"
	elog "\${HOME}/.inkscape to \${HOME}/.config/inkscape within"
	elog ">=media-gfx/inkscape-0.48"
}
