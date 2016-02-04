# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils toolchain-funcs flag-o-matic perl-module mercurial

MY_P=${P/graphicsm/GraphicsM}

DESCRIPTION="GraphicsMagick is the swiss army knife of image processing."
HOMEPAGE="http://www.graphicsmagick.org/"
EHG_REPO_URI="http://hg.code.sf.net/p/graphicsmagick/code"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="bzip2 cxx debug doc fpx imagemagick jbig jpeg jpeg2k lzma lcms modules openmp
	perl png q8 q16 q32 svg threads tiff truetype X wmf zlib"

RDEPEND="app-text/ghostscript-gpl
	bzip2? ( app-arch/bzip2 )
	fpx? ( media-libs/libfpx )
	jbig? ( media-libs/jbigkit )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( >=media-libs/jasper-1.701.0 )
	lcms? ( media-libs/lcms:2 )
	perl? ( dev-lang/perl )
	png? ( media-libs/libpng )
	svg? ( dev-libs/libxml2 )
	tiff? ( >=media-libs/tiff-3.8.2 )
	truetype? ( media-libs/freetype:2 )
	wmf? ( media-libs/libwmf )
	X? ( x11-libs/libXext x11-libs/libSM )
	imagemagick? ( !media-gfx/imagemagick )"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.3.19-perl.patch
	epatch "${FILESDIR}"/${PN}-1.3.20-powerpc.patch
	epatch_user #498942
	eautoreconf
}

src_configure() {
	local quantumDepth=16
	use q8 && quantumDepth=8
	use q32 && quantumDepth=32

	use debug && filter-flags -fomit-frame-pointer
	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--enable-shared \
		--enable-largefile \
		--without-included-ltdl \
		--without-frozenpaths \
		--without-gslib \
		--with-quantum-depth=${quantumDepth} \
		--with-fontpath="${EPREFIX}/usr/share/fonts" \
		--with-gs-font-dir="${EPREFIX}/usr/share/fonts/default/ghostscript" \
		--with-windows-font-dir="${EPREFIX}/usr/share/fonts/corefonts" \
		--with-perl-options="INSTALLDIRS=vendor" \
		$(use_enable debug ccmalloc) \
		$(use_enable debug prof) \
		$(use_enable debug gcov) \
		$(use_enable imagemagick magick-compat) \
		$(use_enable openmp) \
		$(use_with bzip2 bzlib) \
		$(use_with cxx magick-plus-plus) \
		$(use_with fpx) \
		$(use_with jbig) \
		$(use_with jpeg) \
		$(use_with jpeg2k jp2) \
		$(use_with lzma) \
		--without-lcms \
		$(use_with lcms lcms2) \
		$(use_with modules) \
		$(use_with perl) \
		$(use_with png) \
		$(use_with svg xml) \
		$(use_with threads) \
		$(use_with tiff) \
		$(use_with truetype ttf) \
		$(use_with wmf) \
		$(use_with X x) \
		$(use_with zlib)
}

src_compile() {
	default
	use perl && emake perl-build
}

src_test() {
	unset DISPLAY # some perl tests fail when DISPLAY is set
	default
}

src_install() {
	default

	if use perl; then
		emake -C PerlMagick DESTDIR="${D}" install
		find "${ED}" -type f -name perllocal.pod -exec rm -f {} +
		find "${ED}" -depth -mindepth 1 -type d -empty -exec rm -rf {} +
	fi

	find "${ED}" -name '*.la' -exec sed -i -e "/^dependency_libs/s:=.*:='':" {} +
}