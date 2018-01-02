# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit bzr gnome2 cmake-utils flag-o-matic

SRC_URI=""
EBZR_REPO_URI="lp:inkscape"
EBZR_PROJECT="inkscape"

DESCRIPTION="A SVG based generic vector-drawing program"
HOMEPAGE="http://www.inkscape.org/"

SLOT="0"
LICENSE="GPL-2 LGPL-2.1"
KEYWORDS=""
IUSE="dia gs gnome dbus lcms nls poppler postscript python perl wmf wpg"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-cpp/glibmm-2.36
	dev-cpp/gtkmm:2.4
	>=dev-libs/boehm-gc-6.4
	dev-libs/gdl
	>=dev-libs/glib-2.6.5
	>=dev-libs/libsigc++-2.0.12
	>=dev-libs/libxml2-2.6.20
	>=dev-libs/libxslt-1.0.15
	dev-libs/popt
	dev-python/lxml
	|| ( media-gfx/imagemagick[cxx] media-gfx/graphicsmagick[cxx,symlink] )
	media-gfx/potrace
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0
	app-text/libwpd:0.10
	wpg? ( app-text/libwpg:0.3 )
	sci-libs/gsl
	x11-libs/libXft
	x11-libs/gtk+:2
	>=x11-libs/pango-1.4.0
	|| ( dev-lang/python:2.7[xml] dev-python/pyxml )
	gnome? ( >=gnome-base/gnome-vfs-2.0 )
	lcms? ( media-libs/lcms:2 )"

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
	virtual/pkgconfig
	x11-libs/libX11
	>=dev-util/intltool-0.29"

src_unpack() {
	bzr_src_unpack
}

src_prepare() {
	# prevent writing into the real tree
	einfo "Fixing gtk-update-icon-cache path"
	sed -i "/gtk-update-icon-cache -f -t /d" "${S}"/share/icons/application/CMakeLists.txt || die "Failed to update gtk-update-icon-cache path"
}

src_configure(){
	local mycmakeargs=(
		$(cmake-utils_use_with perl PERL)
		$(cmake-utils_use_with python PYTHON)
		$(cmake-utils_use_has poppler POPPLER_CAIRO)
		$(cmake-utils_use_with gnome GNOME_VFS)
		$(cmake-utils_use_with wpg LIBWPG)
		$(cmake-utils_use_with dbus DBUS)
		$(cmake-utils_use_has lcms LIBLCMS2)
		$(cmake-utils_use_enable nls NLS)
	)
	cmake-utils_src_configure

	DOCS="AUTHORS ChangeLog* NEWS README*"

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
