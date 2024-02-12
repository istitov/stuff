# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

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

EAPI="7"
_PYTHON_ALLOW_PY27=1
PYTHON_COMPAT=( python2_7 )
inherit xdg-utils python-single-r1_py2 autotools git-r3

HTDOCSV="20110221"
CIDMAPV="20090121"
DESCRIPTION="postscript font editor and converter"
HOMEPAGE="http://fontforge.sourceforge.net/"
EGIT_REPO_URI="git://fontforge.git.sourceforge.net/gitroot/fontforge/fontforge"
#SRC_URI="git://fontforge.git.sourceforge.net/gitroot/fontforge/fontforge
#	doc? ( mirror://sourceforge/fontforge/fontforge_htdocs-${HTDOCSV}.tar.bz2 )
#	cjk? ( mirror://gentoo/cidmaps-${CIDMAPV}.tgz )"	# http://fontforge.sf.net/cidmaps.tgz

LICENSE="BSD"
SLOT="0"
IUSE="cjk cairo doc gif debug jpeg nls pasteafter png +python tiff tilepath truetype truetype-debugger pango type3 svg unicode +X capslock-for-alt freetype-bytecode freetype devicetables gb12345"

RDEPEND="python? ( dev-lang/python:2.7 )
	gif? ( >=media-libs/giflib-4.1.0-r1 )
	jpeg? ( virtual/jpeg:0 )
	png? ( media-libs/libpng:0 )
	tiff? ( media-libs/tiff:0 )
	truetype? ( >=media-libs/freetype-2.1.4 )
	truetype-debugger? ( >=media-libs/freetype-2.3.8[fontforge,-bindist] )
	svg? ( >=dev-libs/libxml2-2.6.7 )
	unicode? ( >=media-libs/libuninameslist-030713 )
	cairo? ( >=x11-libs/cairo-1.6.4[X] )
	pango? ( >=x11-libs/pango-1.20.3 )
	x11-libs/libXi
	!media-gfx/pfaedit"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python-single-r1_py2_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/${P}-lxkbui.patch"
	epatch "${FILESDIR}/${P}-libz.so-linkage.patch"
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
		--without-native-script \
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
		$(use_with cairo) \
		$(use_with capslock-for-alt) \
		$(use_with iconv) \
		$(use_enable libff) \
		$(use_enable freetype) \
		$(use_with freetype-bytecode) \
		$(use_enable devicetables)
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS README* || die

	find "${ED}" -name '*.la' -exec rm -f {} +

	if use cjk; then #129518
		insinto /usr/share/fontforge
		doins "${WORKDIR}"/*.cidmap || die
	fi

	doicon Packaging/fontforge.png || die
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
	xdg-utils_desktop_database_update
	xdg-utils_mime_database_update
}

pkg_postinst() {
	xdg-utils_desktop_database_update
	xdg-utils_mime_database_update
}
