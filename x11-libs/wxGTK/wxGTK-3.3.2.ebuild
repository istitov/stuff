# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Overlay (::stuff) 3.3-gtk3 slot: ::gentoo ships only 3.2-gtk3 as of
# 2026-06-20, but media-gfx/orcaslicer-2.4.0 requires wxWidgets >=3.3
# (find_package(wxWidgets 3.3 REQUIRED)). Forked from ::gentoo's
# wxGTK-3.2.8.1-r2 to the 3.3.2 release, slot 3.3-gtk3; eselect-owned
# aclocal/bakefile installs are renamed to "33" for parallel install with
# the system 3.2-gtk3 slot, and the overlay's forked wxwidgets.eclass
# accepts 3.3-gtk3. Re-sync with ::gentoo once it carries a 3.3 slot.

inherit edo multilib-minimal flag-o-matic toolchain-funcs

# Make sure that this matches the number of components in ${PV}
WXRELEASE="$(ver_cut 1-2)-gtk3"			# 3.3-gtk3

DESCRIPTION="GTK version of wxWidgets, a cross-platform C++ GUI toolkit"
HOMEPAGE="https://wxwidgets.org/"
SRC_URI="
	https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}.tar.bz2
	doc? ( https://github.com/wxWidgets/wxWidgets/releases/download/v${PV}/wxWidgets-${PV}-docs-html.tar.bz2 )"
S="${WORKDIR}/wxWidgets-${PV}"

LICENSE="wxWinLL-3 GPL-2 doc? ( wxWinFDL-3 )"
SLOT="${WXRELEASE}/3.3"
KEYWORDS="~amd64"
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

# Note about the gst-plugin-base dep: The build system queries for it,
# but doesn't link it for some reason?  Either way - probably best to
# depend on it anyway.
# Note about the wayland dep: Appears to be only required for the OpenGL
# canvas, and it seems impossible to disable the X dependency, unless
# I'm missing something.  This is an automagic header dep, though.

# Patch set trimmed for 3.3.2: ::gentoo's 3.2 configure-tests and
# wayland-control patches are obsolete -- 3.3.2 has native --enable-tests
# and --with-wayland (see src_configure). The remaining two apply fuzz=0.
PATCHES=(
	"${FILESDIR}/${PN}-3.2.1-prefer-lib64-in-tests.patch"
	"${FILESDIR}/${PN}-3.2.5-dont-break-flags.patch"
)

multilib_src_configure() {
	# bug #952961
	tc-is-lto && filter-flags -fno-semantic-interposition

	# Workaround for bug #915154
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	# X independent options
	local myeconfargs=(
		--with-zlib=sys
		--with-expat=sys
		--enable-compat30
		--enable-xrc
		$(use_with sdl)
		$(use_with lzma liblzma)
		# Currently defaults to curl, could change.  Watch the VDB!
		$(use_enable curl webrequest)

		# PCHes are unstable and are disabled in-tree where possible
		# See bug #504204
		# Commits 8c4774042b7fdfb08e525d8af4b7912f26a2fdce, fb809aeadee57ffa24591e60cfb41aecd4823090
		$(use_enable pch precomp-headers)

		# Don't hard-code libdir's prefix for wx-config
		--libdir='${prefix}'/$(get_libdir)
	)

	# By default, we now build with the GLX GLCanvas because some software like
	# PrusaSlicer does not yet support EGL:
	#
	# https://github.com/prusa3d/PrusaSlicer/issues/9774 .
	#
	# A solution for this is being developed upstream:
	#
	# https://github.com/wxWidgets/wxWidgets/issues/22325 .
	#
	# Any software that needs to use OpenGL under Wayland can be patched like
	# this to run under xwayland:
	#
	# https://github.com/visualboyadvance-m/visualboyadvance-m/commit/aca206a721265366728222d025fec30ee500de82 .
	#
	# Check that the macro wxUSE_GLCANVAS_EGL is set to 1.
	#
	myeconfargs+=( "--disable-glcanvasegl" )

	# debug in >=2.9
	# there is no longer separate debug libraries (gtk2ud)
	# wxDEBUG_LEVEL=1 is the default and we will leave it enabled
	# wxDEBUG_LEVEL=2 enables assertions that have expensive runtime costs.
	# apps can disable these features by building w/ -NDEBUG or wxDEBUG_LEVEL_0.
	# http://docs.wxwidgets.org/3.0/overview_debugging.html
	# https://groups.google.com/group/wx-dev/browse_thread/thread/c3c7e78d63d7777f/05dee25410052d9c
	use debug && myeconfargs+=( --enable-debug=max )

	# wxGTK options
	#   --enable-graphics_ctx - needed for webkit, editra
	#   --without-gnomevfs - bug #203389
	use X && myeconfargs+=(
		--enable-graphics_ctx
		--with-gtkprint
		--enable-gui
		--with-gtk=3
		--with-libpng=sys
		--with-libjpeg=sys

		# Choosing to enable this unconditionally seems fair, pcre2 is
		# almost certain to be installed.
		--with-regex=sys
		--without-gnomevfs
		$(use_enable gstreamer mediactrl)
		$(multilib_native_use_enable webkit webview)
		$(use_with libnotify)
		$(use_with opengl)
		$(use_with tiff libtiff sys)
		# WebP is new in wx 3.3 and auto-detects system libwebp, silently
		# falling back to the bundled builtin when "sys" but missing. Gate on
		# USE to avoid that automagic dep; webp? guarantees the sys lib.
		$(use_with webp libwebp sys)
		$(use_enable keyring secretstore)
		$(use_enable spell spellcheck)
		$(use_enable test tests)

		# 3.3.2 has native wayland control; --with-wayland replaces the
		# 3.2-era GENTOO_GTK_HIDE_WAYLAND cppflag hack + wayland-control patch.
		$(use_with wayland)
	)

	# wxBase options
	! use X && myeconfargs+=( --disable-gui )

	# wxWidgets installs a configuration file with a reference to EGREP.
	# Autoconf discovers these programs via full paths, which is
	# unnecessary and fails if a build happened on a merged-usr system
	# but is being used on a split-usr system.  Bug #927920.
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
	# TODO: Use --success for verbose logs, but it seems to change test results?
	# TODO: test_gui too with xvfb-run, as Fedora does?
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

	# Unversioned links
	rm "${ED}"/usr/bin/wx-config || die
	rm "${ED}"/usr/bin/wxrc || die
	# wxwin.m4 is owned by eselect-wxwidgets. Key the rename to this slot ("33")
	# so it coexists with the system 3.2 slot's wxwin32-gtk3.m4.
	mv "${ED}"/usr/share/aclocal/wxwin.m4 "${ED}"/usr/share/aclocal/wxwin33-gtk3.m4 || die

	# version bakefile presets (slot-keyed "33gtk3" to coexist with 3.2's "32gtk3")
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
