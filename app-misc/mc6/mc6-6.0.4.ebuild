# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic optfeature

DESCRIPTION="Midnight Commander fork with dynamically loaded panel plugins"
HOMEPAGE="https://blue-panels.github.io/mc6/ https://github.com/blue-panels/mc6"
# Use the bootstrapped release asset (configure and mc-version.h), not GitHub's
# generated archive; its bytes do not change with archive regeneration.
SRC_URI="https://github.com/blue-panels/mc6/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+edit ftp gpm lua mongodb nls s3 samba sftp +slang spell sqlite test X"

# Spell check is compiled into the internal editor.
REQUIRED_USE="spell? ( edit )"
RESTRICT="!test? ( test )"

# libarchive backs arcmc, the only remaining archive VFS. libmagic and zlib use
# unconditional header probes in core code, so gating them would be automagic.
# verified against 6.0.4 on 2026-09-04
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

# spell has no switch: the built-in editor dlopens libaspell, then libhunspell.
# Upstream keeps PACKAGE="mc", so its binaries and data collide with app-misc/mc.
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

# configure bakes nroff capabilities into installed scripts; require groff so
# their contents do not vary by build host. verified 2026-09-04, configure.ac:84-133
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
	# Versioned because the generated-configure patch needs review on each bump.
	"${FILESDIR}"/${P}-zlib-probe-memset.patch
)

src_configure() {
	# GCC 15.3.1 + LTO miscompiles mctree_node_expand_to_depth (mctree_view 1/7
	# fails); GCC 16.2.0 passes. reproduced 2026-09-04 with -O2 -flto=12
	filter-lto

	# Disable PATH-based Lua-handler probes for reproducible contents; lua-sixel
	# still discovers chafa at runtime, while procyon is unpackaged.
	local -x CHAFA=no PROCYON=no

	local myeconfargs=(
		--disable-static
		--enable-vfs
		# ncursesw is no longer a valid value; the ncurses branch probes wide first.
		# verified 2026-09-04, m4.include/mc-with-screen*.m4
		--with-screen=$(usex slang slang ncurses)
		# Internal-only mclib also collides with sci-libs/mc (bug #685938).
		--disable-mclib
		$(use_enable kernel_linux ext2fs-attr)
		$(use_enable nls)
		$(use_enable test tests)
		$(use_with gpm gpm-mouse)
		$(use_with X x)
		$(use_with edit internal-edit)

		# Pin auto-detected plugins to USE; =yes makes core plugin failures fatal.
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

	# GModule loads panel and Lua plugins directly; their .la files are unused.
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
	# BDEPEND does not keep nroff installed for ext.d/text.sh at runtime.
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
