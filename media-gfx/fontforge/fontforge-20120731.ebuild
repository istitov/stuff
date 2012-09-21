# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/fontforge/fontforge-20110222-r1.ebuild,v 1.7 2012/05/09 02:09:37 aballier Exp $

# Some notes for maintainers this package:
# 1. README-unix: freetype headers are required to make use of truetype debugger
# in fontforge.
# 2. --enable-{double,longdouble} these just make ff use more storage space. In
# normal fonts neither is useful. Leave off.
# 3. FontForge autodetects libraries but does not link with them. They are
# dynamically loaded at run time if fontforge found them at build time.
# --with-regular-link disables this behaviour. No reason to make it optional for
# users. http://fontforge.sourceforge.net/faq.html#libraries. To see what
# libraries fontforge thinks with use $ fontforge --library-status

EAPI=3

PYTHON_DEPEND="python? 2"
inherit eutils fdo-mime python autotools

MY_PV="${PV}-b"
HTDOCSV="${PV}-b"
CIDMAPV="20090121"
DESCRIPTION="postscript font editor and converter"
HOMEPAGE="http://fontforge.sourceforge.net/"
SRC_URI="mirror://sourceforge/fontforge/${PN}_full-${MY_PV}.tar.bz2
doc? ( mirror://sourceforge/fontforge/fontforge_htdocs-${HTDOCSV}.tar.bz2 )
cjk? ( mirror://gentoo/cidmaps-${CIDMAPV}.tgz )"	# http://fontforge.sf.net/cidmaps.tgz

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="cjk cairo doc gif debug jpeg nls pasteafter png +python tiff tilepath truetype truetype-debugger pango type3 svg unicode +X"

	RDEPEND="gif? ( >=media-libs/giflib-4.1.0-r1 )
	jpeg? ( virtual/jpeg )
	png? ( >=media-libs/libpng-1.2.4 )
	tiff? ( >=media-libs/tiff-3.5.7-r1 )
	truetype? ( >=media-libs/freetype-2.1.4 )
	truetype-debugger? ( >=media-libs/freetype-2.3.8[fontforge,-bindist] )
	svg? ( >=dev-libs/libxml2-2.6.7 )
	unicode? ( >=media-libs/libuninameslist-030713 )
	cairo? ( >=x11-libs/cairo-1.6.4[X] )
pango? ( >=x11-libs/pango-1.20.3 )
	x11-libs/libXi
	x11-proto/inputproto
	!media-gfx/pfaedit"
	DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

	S="${WORKDIR}/${PN}-${MY_PV}"

	pkg_setup() {
		if use python; then
			python_set_active_version 2
				python_pkg_setup
				fi
	}

src_unpack() {
	unpack ${PN}_full-${MY_PV}.tar.bz2
		use cjk && unpack cidmaps-${CIDMAPV}.tgz
		if use doc; then
			mkdir html
				cd html
				unpack fontforge_htdocs-${HTDOCSV}.tar.bz2
				fi
}

src_prepare() {
	if use doc; then
		chmod -x "${WORKDIR}"/html/*.html || die
								fi
								eautoconf
								}

								src_configure() {
# no real way of disabling gettext/nls ...
use nls || export ac_cv_header_libintl_h=no
econf \
--disable-static \
$(use_with truetype-debugger freetype-src "/usr/include/freetype2/internal4fontforge/") \
$(use_enable type3) \
$(use_with python) \
$(use_enable python pyextension) \
$(use_enable pasteafter) \
$(use_with X x) \
$(use_enable cjk gb12345) \
$(use_enable tilepath) \
$(use_enable debug debug-raw-points) \
$(use_with pango) \
$(use_with cairo)
}

src_install() {
emake install DESTDIR="${D}" || die
dodoc AUTHORS README* || die

find "${ED}" -name '*.la' -exec rm -f {} +

if use cjk; then #129518
insinto /usr/share/fontforge
doins "${WORKDIR}"/*.cidmap || die
fi

for isize in 16 22 24 32 48
do	
doicon -s ${isize} Packaging/icons/${isize}x${isize}/apps/fontforge.png || die
done
doicon -s scalable Packaging/icons/scalable/apps/fontforge.svg || die
insinto /usr/share/applications
doins Packaging/fontforge.desktop || die
insinto /usr/share/mime/application
doins Packaging/fontforge.xml || die

if use doc; then
insinto /usr/share/doc/${PN}
cd "${WORKDIR}/html/"
doins -r * || die
fi
}

pkg_postrm() {
fdo-mime_desktop_database_update
fdo-mime_mime_database_update
}

pkg_postinst() {
fdo-mime_desktop_database_update
fdo-mime_mime_database_update
}
