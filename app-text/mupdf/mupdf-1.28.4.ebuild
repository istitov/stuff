# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Check upstream git regularly for security fixes to backport.

inherit desktop flag-o-matic toolchain-funcs xdg

DESCRIPTION="A lightweight PDF viewer and toolkit written in portable C"
HOMEPAGE="https://mupdf.com/ https://cgit.ghostscript.com/mupdf.git/"
SRC_URI="https://mupdf.com/downloads/archive/${P}-source.tar.gz"
S="${WORKDIR}"/${P}-source

LICENSE="AGPL-3"
SLOT="0/${PV}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="archive barcode brotli +javascript +jpeg2k opengl ssl X"
REQUIRED_USE="opengl? ( javascript )"

# Bundled patched freeglut still relies on the system package for dependencies
# (bug #653298).
RDEPEND="
	archive? ( app-arch/libarchive )
	barcode? ( media-libs/zxing-cpp:= )
	brotli? ( app-arch/brotli:= )
	dev-libs/gumbo:=
	media-libs/freetype:2
	media-libs/harfbuzz:=[truetype]
	media-libs/jbig2dec:=
	media-libs/libpng:0=
	>=media-libs/libjpeg-turbo-1.5.3-r2:0=
	net-misc/curl
	javascript? ( >=dev-lang/mujs-1.3.8:= )
	jpeg2k? ( >=media-libs/openjpeg-2.1:2= )
	opengl? ( >=media-libs/freeglut-3.0.0 )
	ssl? ( >=dev-libs/openssl-1.1:0= )
	virtual/zlib:=
	X? (
		media-libs/libglvnd[X]
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXrandr
	)
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-1.15-CFLAGS.patch
	"${FILESDIR}"/${P}-Makefile.patch
	"${FILESDIR}"/${PN}-1.24.8-add-desktop-pc-files.patch
	"${FILESDIR}"/${P}-cross-fixes.patch
	"${FILESDIR}"/${PN}-1.24.1-darwin.patch
	# See bug #662352
	"${FILESDIR}"/${P}-openssl-x11.patch
	# General cross fixes from Debian (refreshed)
	"${FILESDIR}"/${PN}-1.21.1-fix-aliasing-violation.patch
)

src_prepare() {
	default

	use hppa && append-cflags -ffunction-sections

	append-cflags "-DFZ_ENABLE_JS=$(usex javascript 1 0)"

	if ! use jpeg2k; then
		append-cflags "-DFZ_ENABLE_JPX=0"
		sed -i '/_OPENJPEG_/d' Makerules || die
		# See https://github.com/ArtifexSoftware/mupdf/pull/60
		sed -i '/openjpeg.h/d' 'source/fitz/encode-jpx.c' || die
	fi

	sed -e "1iOS = Linux" \
		-e "1iCC = $(tc-getCC)" \
		-e "1iCXX = $(tc-getCXX)" \
		-e "1iLD = $(tc-getLD)" \
		-e "1iAR = $(tc-getAR)" \
		-e "1iverbose = yes" \
		-e "1ibuild = debug" \
		-e "1ibarcode = $(usex barcode)" \
		-e "1ibrotli = $(usex brotli)" \
		-e "1imujs = $(usex javascript)" \
		-i Makerules || die "Failed adding build variables to Makerules in src_prepare()"

	sed -e "s/Version: \(.*\)/Version: ${PV}/" \
		-i platform/debian/${PN}.pc || die "Failed substituting version in ${PN}.pc"
}

_emake() {
	# HAVE_OBJCOPY=yes produces QA warnings; USE_SYSTEM_LIBS selects upstream's
	# recommended mix, not every system library. Keep patched freeglut for
	# clipboard support (#653298) and Artifex's lcms2 fork. Recheck system mujs
	# compatibility on bumps (#685244).
	local myemakeargs=(
		GENTOO_PV=${PV}
		HAVE_GLUT=$(usex opengl)
		HAVE_LIBCRYPTO=$(usex ssl)
		HAVE_X11=$(usex X)
		HAVE_ZXINGCPP=$(usex barcode)
		HAVE_MUJS=$(usex javascript)
		HAVE_SYS_ZXINGCPP=$(usex barcode)
		USE_SYSTEM_LIBS=yes
		USE_SYSTEM_BROTLI=$(usex brotli)
		USE_SYSTEM_GLUT=no
		USE_SYSTEM_MUJS=$(usex javascript)
		USE_SYSTEM_ZXINGCPP=$(usex barcode)
		HAVE_OBJCOPY=no
		"$@"
	)

	emake "${myemakeargs[@]}"
}

src_compile() {
	tc-export PKG_CONFIG

	_emake XCFLAGS="-fPIC"
}

src_install() {
	if use opengl || use X ; then
		domenu platform/debian/${PN}.desktop
		doicon -s scalable docs/logo/${PN}-icon.svg
	else
		rm docs/man/${PN}.1 || die "Failed to remove man page in src_install()"
	fi

	sed -i \
		-e "1iprefix = ${ED}/usr" \
		-e "1ilibdir = ${ED}/usr/$(get_libdir)" \
		-e "1idocdir = ${ED}/usr/share/doc/${PF}" \
		-i Makerules || die "Failed adding liprefix, lilibdir and lidocdir to Makerules in src_install()"

	_emake install

	dosym libmupdf.so.${PV} /usr/$(get_libdir)/lib${PN}.so

	if use opengl ; then
		einfo "mupdf symlink points to mupdf-gl (bug 616654)"
		dosym ${PN}-gl /usr/bin/${PN}
	elif use X ; then
		einfo "mupdf symlink points to mupdf-x11 (bug 616654)"
		dosym ${PN}-x11 /usr/bin/${PN}
	fi

	# Respect libdir and EPREFIX (bugs #734898, #911965)
	sed -i -e "s:/lib:/$(get_libdir):" \
		-e "s:/usr:${EPREFIX}/usr:" platform/debian/${PN}.pc \
		|| die "Failed to sed pkgconfig file to respect libdir and EPREFIX in src_install()"

	insinto /usr/$(get_libdir)/pkgconfig
	doins platform/debian/${PN}.pc

	dodoc README CHANGES CONTRIBUTORS
}
