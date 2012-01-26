# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/imagemagick/imagemagick-6.7.4.8.ebuild,v 1.1 2012/01/23 22:54:00 ssuominen Exp $

EAPI=4
inherit multilib toolchain-funcs versionator

MY_P=ImageMagick-$(replace_version_separator 3 '-')

DESCRIPTION="A collection of tools and libraries for many image formats"
HOMEPAGE="http://www.imagemagick.org/"
SRC_URI="http://image_magick.veidrodis.com/image_magick/${MY_P}.tar.xz 
http://www.imagemagick.org/download/${MY_P}.tar.xz 
mirror://${PN}/${MY_P}.tar.xz"

LICENSE="imagemagick"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="autotrace bzip2 corefonts cxx djvu fftw fontconfig fpx graphviz gs hdri jbig jpeg jpeg2k lcms lqr lzma opencl openexr openmp pango perl png q32 q64 q8 raw static-libs svg tiff truetype webp wmf X xml zlib"

RDEPEND=">=sys-devel/libtool-2.2.6b
	autotrace? ( >=media-gfx/autotrace-0.31.1 )
	bzip2? ( app-arch/bzip2 )
	corefonts? ( media-fonts/corefonts )
	djvu? ( app-text/djvu )
	fftw? ( sci-libs/fftw:3.0 )
	fontconfig? ( media-libs/fontconfig )
	fpx? ( >=media-libs/libfpx-1.3.0-r1 )
	graphviz? ( >=media-gfx/graphviz-2.6 )
	gs? ( app-text/ghostscript-gpl )
	jbig? ( media-libs/jbigkit )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/jasper )
	lcms? ( media-libs/lcms:2 )
	lqr? ( >=media-libs/liblqr-0.1.0 )
	opencl? ( virtual/opencl )
	openexr? ( media-libs/openexr )
	pango? ( x11-libs/pango )
	perl? ( >=dev-lang/perl-5.8.6-r6 )
	png? ( media-libs/libpng:0 )
	raw? ( media-gfx/ufraw )
	svg? ( >=gnome-base/librsvg-2.9.0 )
	tiff? ( media-libs/tiff:0 )
	truetype? ( media-libs/freetype:2 )
	webp? ( media-libs/libwebp )
	wmf? ( >=media-libs/libwmf-0.2.8 )
	X? (
		x11-libs/libXext
		x11-libs/libXt
		x11-libs/libICE
		x11-libs/libSM
	)
	xml? ( >=dev-libs/libxml2-2.4.10 )
	lzma? ( app-arch/xz-utils )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	!media-gfx/graphicsmagick[imagemagick]
	app-arch/xz-utils
	dev-util/pkgconfig
	>=sys-apps/sed-4
	X? ( x11-proto/xextproto )"

REQUIRED_USE="corefonts? ( truetype )"

S=${WORKDIR}/${MY_P}

RESTRICT="perl? ( userpriv )"

DOCS=( AUTHORS.txt ChangeLog NEWS.txt README.txt )

src_configure() {
	local depth=16
	use q8 && depth=8
	use q32 && depth=32
	use q64 && depth=64

	local openmp=disable
	if use openmp && tc-has-openmp; then
		openmp=enable
	fi

	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_enable static-libs static) \
		$(use_enable hdri) \
		$(use_enable opencl) \
		--with-threads \
		--without-included-ltdl \
		--with-ltdl-include="${EPREFIX}/usr/include" \
		--with-ltdl-lib="${EPREFIX}/usr/$(get_libdir)" \
		--with-modules \
		--with-quantum-depth=${depth} \
		$(use_with cxx magick-plus-plus) \
		$(use_with perl) \
		--with-perl-options='INSTALLDIRS=vendor' \
		--with-gs-font-dir="${EPREFIX}/usr/share/fonts/default/ghostscript" \
		$(use_with bzip2 bzlib) \
		$(use_with X x) \
		$(use_with zlib) \
		$(use_with autotrace) \
		$(use_with gs dps) \
		$(use_with djvu) \
		--with-dejavu-font-dir="${EPREFIX}/usr/share/fonts/dejavu" \
		$(use_with fftw) \
		$(use_with fpx) \
		$(use_with fontconfig) \
		$(use_with truetype freetype) \
		$(use_with gs gslib) \
		$(use_with graphviz gvc) \
		$(use_with jbig) \
		$(use_with jpeg) \
		$(use_with jpeg2k jp2) \
		--without-lcms \
		$(use_with lcms lcms2) \
		$(use_with lqr) \
		$(use_with lzma) \
		$(use_with openexr) \
		$(use_with pango) \
		$(use_with png) \
		$(use_with svg rsvg) \
		$(use_with tiff) \
		$(use_with webp) \
		$(use_with corefonts windows-font-dir /usr/share/fonts/corefonts) \
		$(use_with wmf) \
		$(use_with xml) \
		--${openmp}-openmp
}

src_test() {
	if has_version ~${CATEGORY}/${P}; then
		emake -j1 check
	else
		ewarn "Skipping tests because installed version doesn't match."
	fi
}

src_install() {
	default

	if use perl; then
		find "${ED}" -type f -name perllocal.pod -exec rm -f {} +
		find "${ED}" -depth -mindepth 1 -type d -empty -exec rm -rf {} +
	fi

	find "${ED}" -name '*.la' -exec sed -i -e "/^dependency_libs/s:=.*:='':" {} +
}
