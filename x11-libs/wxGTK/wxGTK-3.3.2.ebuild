# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# media-gfx/orcaslicer requires wxWidgets 3.3, absent from ::gentoo as of
# 2026-06-20. Slot-suffixed eselect files permit parallel 3.2/3.3 installs;
# the overlay wxwidgets.eclass supports 3.3-gtk3. Resync once Gentoo does.

inherit edo multilib-minimal flag-o-matic toolchain-funcs

WXRELEASE="$(ver_cut 1-2)-gtk3"

DESCRIPTION="GTK version of wxWidgets, a cross-platform C++ GUI toolkit"
HOMEPAGE="https://wxwidgets.org/"
SRC_URI="
	https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}.tar.bz2
	doc? ( https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}-docs-html.tar.bz2 )"
S="${WORKDIR}/wxWidgets-${PV}"

LICENSE="wxWinLL-3 GPL-2 doc? ( wxWinFDL-3 )"
SLOT="${WXRELEASE}/3.3"
KEYWORDS="~amd64 ~arm64"
IUSE="+X curl doc debug keyring gstreamer libnotify +lzma opengl pch sdl +spell test tiff wayland webkit webp X"
REQUIRED_USE="test? ( tiff ) tiff? ( X ) webp? ( X ) spell? ( X ) keyring? ( X )"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-eselect/eselect-wxwidgets-20131230
	dev-libs/expat[${MULTILIB_USEDEP}]
	dev-libs/libpcre2[pcre16,pcre32,unicode]
	sdl? ( media-libs/libsdl2[${MULTILIB_USEDEP}] )
	curl? ( net-misc/curl )
	lzma? ( app-arch/xz-utils )
	X? (
		>=dev-libs/glib-2.22:2[${MULTILIB_USEDEP}]
		media-libs/libjpeg-turbo:=[${MULTILIB_USEDEP}]
		media-libs/libpng:0=[${MULTILIB_USEDEP}]
		virtual/zlib:=[${MULTILIB_USEDEP}]
		x11-libs/cairo[${MULTILIB_USEDEP}]
		>=x11-libs/gtk+-3.24.41-r1:3[wayland?,X?,${MULTILIB_USEDEP}]
		x11-libs/gdk-pixbuf:2[${MULTILIB_USEDEP}]
		x11-libs/libSM[${MULTILIB_USEDEP}]
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXtst
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
		media-libs/fontconfig
		x11-libs/pango[${MULTILIB_USEDEP}]
		keyring? ( app-crypt/libsecret )
		gstreamer? (
			media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
			media-libs/gst-plugins-base:1.0[${MULTILIB_USEDEP}]
			media-libs/gst-plugins-bad:1.0[${MULTILIB_USEDEP}]
		)
		libnotify? ( x11-libs/libnotify[${MULTILIB_USEDEP}] )
		opengl? (
			virtual/opengl[${MULTILIB_USEDEP}]
			wayland? ( dev-libs/wayland )
		)
		spell? ( app-text/gspell:= )
		tiff? ( media-libs/tiff:=[${MULTILIB_USEDEP}] )
		webp? ( media-libs/libwebp:=[${MULTILIB_USEDEP}] )
		webkit? ( net-libs/webkit-gtk:4.1= )
	)"
DEPEND="${RDEPEND}
	opengl? ( virtual/glu[${MULTILIB_USEDEP}] )
	X? ( x11-base/xorg-proto )"
BDEPEND="
	test? ( >=dev-util/cppunit-1.8.0 )
	>=app-eselect/eselect-wxwidgets-20131230
	virtual/pkgconfig"

# gst-plugins-base is detected but apparently not linked; keep the dependency.
# Wayland is an automagic GLCanvas header dep and does not replace X for GUI builds.

# wxWidgets 3.3 has native test and Wayland configure switches, superseding
# Gentoo's 3.2 patches. The retained Gentoo patches apply with fuzz=0.
PATCHES=(
	"${FILESDIR}/${PN}-3.2.1-prefer-lib64-in-tests.patch"
	"${FILESDIR}/${PN}-3.2.5-dont-break-flags.patch"
)

multilib_src_configure() {
	# LTO conflicts with -fno-semantic-interposition (bug #952961).
	tc-is-lto && filter-flags -fno-semantic-interposition

	# Permit version scripts to reference absent symbols (bug #915154).
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local myeconfargs=(
		--with-zlib=sys
		--with-expat=sys
		--enable-compat30
		--enable-xrc
		$(use_with sdl)
		$(use_with lzma liblzma)
		# Pin the current curl default.
		$(use_enable curl webrequest)

		# PCH is unstable and disabled where possible. bug #504204
		$(use_enable pch precomp-headers)

		# Avoid a hard-coded wx-config libdir prefix.
		--libdir='${prefix}'/$(get_libdir)
	)

	# Default to GLX: PrusaSlicer lacks EGL support (PrusaSlicer#9774), pending
	# wxWidgets#22325. Wayland applications can run via XWayland.
	myeconfargs+=( "--disable-glcanvasegl" )

	# debug=max enables costly level-2 assertions; no separate debug libs exist.
	use debug && myeconfargs+=( --enable-debug=max )

	# graphics_ctx is required by webkit/editra; disable gnomevfs per bug #203389.
	use X && myeconfargs+=(
		--enable-graphics_ctx
		--with-gtkprint
		--enable-gui
		--with-gtk=3
		--with-libpng=sys
		--with-libjpeg=sys

		# PCRE2 is an unconditional dependency.
		--with-regex=sys
		--without-gnomevfs
		$(use_enable gstreamer mediactrl)
		$(multilib_native_use_enable webkit webview)
		$(use_with libnotify)
		$(use_with opengl)
		$(use_with tiff libtiff sys)
		# Avoid WebP autodetection and bundled fallback; USE guarantees the sys lib.
		$(use_with webp libwebp sys)
		$(use_enable keyring secretstore)
		$(use_enable spell spellcheck)
		$(use_enable test tests)

		# Native in 3.3; replaces the 3.2 cppflag hack and control patch.
		$(use_with wayland)
	)

	! use X && myeconfargs+=( --disable-gui )

	# Keep build-host paths out of installed config across merged/split usr. bug #927920
	export ac_cv_path_SED="sed"
	export ac_cv_path_EGREP="grep -E"
	export ac_cv_path_EGREP_TRADITIONAL="grep -E"
	export ac_cv_path_FGREP="grep -F"
	export ac_cv_path_GREP="grep"
	export ac_cv_path_lt_DD="dd"

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_test() {
	pushd tests >/dev/null || die

	emake
	# Run the reliable non-network subset; GUI tests still need Xvfb.
	edo ./test '~[.]~[net]'

	popd >/dev/null || die
}

multilib_src_install_all() {
	cd docs || die
	dodoc changes.txt readme.txt
	newdoc base/readme.txt base_readme.txt
	newdoc gtk/readme.txt gtk_readme.txt

	use doc && HTML_DOCS=( "${WORKDIR}"/wxWidgets-${PV}-docs-html/. )
	einstalldocs

	# Eselect owns the unversioned links.
	rm "${ED}"/usr/bin/wx-config || die
	rm "${ED}"/usr/bin/wxrc || die
	# Slot suffix avoids collision with eselect's 3.2 file.
	mv "${ED}"/usr/share/aclocal/wxwin.m4 "${ED}"/usr/share/aclocal/wxwin33-gtk3.m4 || die

	# Slot-key bakefile presets for parallel 3.2/3.3 installs.
	pushd "${ED}"/usr/share/bakefile/presets >/dev/null || die
	local f
	for f in wx*; do
		mv "${f}" "${f/wx/wx33gtk3}" || die
	done
	popd >/dev/null || die
}

pkg_postinst() {
	has_version -b app-eselect/eselect-wxwidgets \
		&& eselect wxwidgets update
}

pkg_postrm() {
	has_version -b app-eselect/eselect-wxwidgets \
		&& eselect wxwidgets update
}
