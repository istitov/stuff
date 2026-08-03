# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit flag-o-matic fortran-2 python-any-r1

DESCRIPTION="Suite of interactive programs for XAFS analysis"
HOMEPAGE="https://sourceforge.net/projects/ifeffit/"
SRC_URI="https://archive.ubuntu.com/ubuntu/pool/multiverse/${P:0:1}/${PN}/${PN}_${PV}.orig.tar.gz"

S="${WORKDIR}/${PN}-${PV}"
LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/libpng:=
	sci-libs/pgplot:=
	sys-libs/ncurses:=
	sys-libs/readline:=
	virtual/zlib:=
	x11-libs/libX11:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-lang/perl
"

PATCHES=(
	"${FILESDIR}"/configuration_patches
	"${FILESDIR}"/documentation_patches
	"${FILESDIR}"/fortran_patches
	"${FILESDIR}"/readline_6.3_patch
	"${FILESDIR}"/unescaped-left-brace.patch
	"${FILESDIR}"/wrapper_patches
	"${FILESDIR}"/${P}-modern-build.patch
)

src_configure() {
	# src/cmdline/iff_shell.c uses K&R prototypes (e.g. `char *stripwhite()`
	# then defined with arguments). gcc 16's default (-std=gnu23) treats
	# the empty `()` as `(void)` and rejects the definitions with
	# 'conflicting types'. Pin to gnu89 so K&R survives. verified
	# 2026-05-09.
	append-cflags -std=gnu89

	python_setup
	PYTHON="${PYTHON}" econf \
		--with-pgplot-link="-lpgplot -lX11 -lpng -lz" \
		--with-termcap-link="-lncurses"
}

src_install() {
	emake DESTDIR="${D}" install
	rm "${ED}"/usr/$(get_libdir)/libnopgplot.a || die

	# Autoconf includes compiler-specific -L paths in FLIBS.  They become
	# stale after a compiler upgrade and are unnecessary in standard paths.
	local config
	for config in Config.mak Makefile.PL TclSetup.in site_install.py; do
		sed -E -i 's|-L/[^[:space:]"]+[[:space:]]*||g' \
			"${ED}"/usr/share/${PN}/config/${config} || die
	done

	einstalldocs
}
