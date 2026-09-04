# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic optfeature

DESCRIPTION="Midnight Commander fork with dynamically loaded panel plugins"
HOMEPAGE="https://blue-panels.github.io/mc6/ https://github.com/blue-panels/mc6"
# Release asset, not the /archive/ tarball: bootstrapped (ships configure and
# mc-version.h), so no autoreconf, and an uploaded blob, so it cannot be
# rehashed under us.
SRC_URI="https://github.com/blue-panels/mc6/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+edit ftp gpm lua mongodb nls s3 samba sftp +slang spell sqlite test X"

# Spell check is compiled into the internal editor.
REQUIRED_USE="spell? ( edit )"
RESTRICT="!test? ( test )"

# Unconditional, not USE-gated:
#   libarchive - arcmc replaces the tarfs and cpiofs VFS modules this fork
#     deleted; without it mc6 opens no archive at all.
#   libmagic   - bare AC_CHECK_HEADERS for core MIME matching, on top of the
#     mctree use --enable-mctree-magic gates. A USE flag would turn off only
#     the latter and leave the automagic.
#   zlib       - same shape, bare AC_CHECK_HEADERS([zlib.h]); mcstruct inflate.
# verified 2026-09-04 against the 6.0.4 tarball
COMMON_DEPEND="
	>=dev-libs/glib-2.58:2
	>=app-arch/libarchive-3.0:=
	sys-apps/file
	virtual/zlib:=
	ftp? ( >=net-misc/curl-7.20.0 )
	gpm? ( sys-libs/gpm )
	kernel_linux? ( >=sys-fs/e2fsprogs-1.42.4 )
	lua? ( dev-lang/lua:5.4 )
	mongodb? (
		>=dev-libs/libbson-1.21
		>=dev-libs/mongo-c-driver-1.21
	)
	s3? ( >=net-misc/curl-7.75.0 )
	samba? ( net-fs/samba[client] )
	sftp? ( >=net-libs/libssh2-1.9.0 )
	slang? ( >=sys-libs/slang-2 )
	!slang? ( sys-libs/ncurses:= )
	sqlite? ( >=dev-db/sqlite-3.26:3 )
	X? ( x11-libs/libX11 )
"

DEPEND="
	${COMMON_DEPEND}
	X? ( x11-base/xorg-proto )
"

# spell has no configure switch: the checker is compiled into the internal
# editor and g_module_opens libaspell.so.N, then libhunspell, at run time.
#
# PACKAGE stays "mc" upstream (gettext domain and every data path derive from
# it), so this owns /usr/bin/mc, the mcedit/mcview/mcdiff/mctree symlinks,
# /usr/share/mc and /usr/libexec/mc -- app-misc/mc's files. Upstream's Debian
# packaging says the same with Conflicts/Replaces/Provides: mc.
RDEPEND="
	${COMMON_DEPEND}
	dev-lang/perl
	!sftp? ( virtual/ssh )
	spell? (
		|| (
			app-text/aspell
			app-text/hunspell
		)
	)
	!!app-misc/mc
"

# groff: configure probes nroff for -mandoc, -c and -Tlatin1 and substitutes
# the answers into misc/ext.d/text.sh and misc/mc.menu, both installed. Absent,
# they fall back to "-man" with no flags, so installed content would vary by
# build host. Not in @system. verified 2026-09-04, configure.ac:84-133
BDEPEND="
	dev-lang/perl
	sys-apps/groff
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	test? ( dev-libs/check )
"

DOCS=( AUTHORS CHANGELOG.md README.md doc/{FAQ,NEWS,PLUGINS,README,TODO} )

PATCHES=(
	"${FILESDIR}"/${PN}-gentoo-tools.patch
	# ${P}, not ${PN}: patches the generated configure by line context, so a
	# bump must re-verify it rather than inherit it silently.
	"${FILESDIR}"/${P}-zlib-probe-memset.patch
)

src_configure() {
	# GCC 15 + LTO leaves the recursion in mctree_node_expand_to_depth unrun,
	# so mctree opens collapsed. Reproduced 2026-09-04, GCC 15.3.1, -O2
	# -flto=12: mctree_view fails 1/7 --
	# test_collapse_from_transparent_child_focuses_visible_parent asserts
	# row_count == 3, gets 2. GCC 16.2.0, same flags: 7/7.
	filter-lto

	# AC_PATH_PROG probes gating Lua handlers on the build host's PATH. Pinned
	# off so USE=lua installs the same set everywhere; lua-sixel still uses
	# chafa at run time, and procyon is unpackaged.
	local -x CHAFA=no PROCYON=no

	local myeconfargs=(
		--disable-static
		--enable-vfs
		# slang or ncurses only -- app-misc/mc's ncursesw value is now an
		# error, and there is no USE=unicode to pass on: the ncurses branch
		# AC_SEARCH_LIBS runs ncursesw then ncurses with no way to force the
		# narrow one. verified 2026-09-04, m4.include/mc-with-screen*.m4
		--with-screen=$(usex slang slang ncurses)
		# As app-misc/mc: mclib exposes no headers, is linked only into the
		# mc binary, and collides with sci-libs/mc (bug #685938).
		--disable-mclib
		$(use_enable kernel_linux ext2fs-attr)
		$(use_enable nls)
		$(use_enable test tests)
		$(use_with gpm gpm-mouse)
		$(use_with X x)
		$(use_with edit internal-edit)

		# Every switch below defaults to "auto" and drops its plugin silently
		# when the library is missing; pinning makes the feature set follow
		# USE. The =yes ones turn that silence into a hard error.
		--enable-mctree-magic=yes
		--enable-panel-plugin-arcmc=yes
		# Works over an external ssh; USE=sftp only adds libssh2 password auth.
		--enable-panel-plugin-shell-link=yes
		$(use_enable ftp panel-plugin-ftp)
		$(use_enable lua lua-plugin)
		$(use_enable mongodb panel-plugin-mongo)
		$(use_enable s3 panel-plugin-s3)
		$(use_enable samba panel-plugin-samba)
		$(use_enable sftp panel-plugin-sftp)
		$(use_enable sftp shell-ssh2)
		$(use_enable sqlite panel-plugin-sqlite)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Panel plugins and the Lua runtime are GModule-dlopened modules, so the
	# .la files describe a link step nothing performs. (Editor plugins --
	# spell, ctags, etags -- are compiled into the editor, not modules.)
	find "${ED}" -name '*.la' -delete || die

	# bug #334383
	if use kernel_linux && [[ ${EUID} == 0 ]] ; then
		fowners root:tty /usr/libexec/mc/cons.saver
		fperms g+s /usr/libexec/mc/cons.saver
	fi
}

pkg_postinst() {
	optfeature "Git panel" dev-vcs/git
	optfeature "Docker panel" app-containers/docker-cli
	optfeature "Kubernetes panel" sys-cluster/kubectl
	# BDEPEND only, so portage will not keep it merged; ext.d/text.sh runs
	# nroff on every man page.
	optfeature "viewing man pages" sys-apps/groff
	if use lua ; then
		optfeature "image previews in the Lua viewer" "media-gfx/chafa[tools]"
	fi

	elog "Other ${PN} extension scripts depend on external tools; install them as needed"
	elog
	if use spell ; then
		elog "The editor's spell checker needs a dictionary for the language you"
		elog "write in: an app-dicts/aspell-* or app-dicts/myspell-* package."
		elog
	fi
	elog "To enable exiting to latest working directory,"
	elog "put this into your ~/.bashrc:"
	elog ". ${EPREFIX}/usr/libexec/mc/mc.sh"
}
