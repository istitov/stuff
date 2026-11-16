# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# meson.eclass supports EAPI 7 and 8 only. verified 2026-11-16
EAPI=8

inherit flag-o-matic meson optfeature

DESCRIPTION="Midnight Commander fork with dynamically loaded panel plugins"
HOMEPAGE="https://github.com/blue-panels/mcommander"
# Use the release asset, not GitHub's generated archive: it carries the
# .tarball-version that version.sh reads outside a git checkout, and its bytes
# do not change with archive regeneration.
SRC_URI="https://github.com/blue-panels/mcommander/releases/download/v${PV}/${P}.tar.gz"

# The diff viewer bundles git's xdiff: LGPL-2.1+, and the Eclipse Distribution
# License (BSD-3-Clause) for xhistogram.c. verified 2026-11-16
LICENSE="GPL-3+ LGPL-2.1+ BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="acl +edit ftp gpm jpeg lua mongodb nls png postgres s3 samba sftp +slang spell sqlite test X"

# Spell check is compiled into the internal editor.
REQUIRED_USE="spell? ( edit )"
RESTRICT="!test? ( test )"

# libarchive backs arcmc, the only remaining archive VFS. libmagic and zlib are
# pinned on below rather than left to auto-detection. verified against 6.2.0
# on 2026-11-16
COMMON_DEPEND="
	>=dev-libs/glib-2.58:2
	>=app-arch/libarchive-3.0:=
	sys-apps/file
	virtual/zlib:=
	acl? ( sys-apps/acl )
	ftp? ( >=net-misc/curl-7.20.0 )
	gpm? ( sys-libs/gpm )
	jpeg? ( media-libs/libjpeg-turbo:= )
	kernel_linux? ( >=sys-fs/e2fsprogs-1.42.4 )
	lua? ( dev-lang/lua:5.4 )
	mongodb? (
		>=dev-libs/libbson-1.21
		>=dev-libs/mongo-c-driver-1.21
	)
	png? ( media-libs/libpng:= )
	postgres? ( >=dev-db/postgresql-10:* )
	s3? ( >=net-misc/curl-7.75.0 )
	samba? ( net-fs/samba:=[client] )
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
"

# meson.build bakes nroff capabilities and the perl path into installed
# scripts; require both so their contents do not vary by build host. verified
# 2026-11-16, meson.build:390-433
BDEPEND="
	dev-lang/perl
	sys-apps/groff
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	test? ( dev-libs/check )
"

DOCS=( AUTHORS CHANGELOG.md README.md doc/{FAQ,NEWS,PLUGINS,README} )

PATCHES=(
	"${FILESDIR}"/${PN}-gentoo-tools.patch
)

src_prepare() {
	default

	# The lua-chafa and lua-java-class viewers install only when chafa or
	# procyon is on PATH at build time. Leave both out for reproducible
	# contents: lua-sixel still discovers chafa at runtime, and procyon is
	# unpackaged. verified 2026-11-16
	sed -i \
		-e "s/^chafa = find_program('chafa', required: false)$/chafa = dependency('', required: false)/" \
		-e "s/^procyon = find_program('procyon', required: false)$/procyon = dependency('', required: false)/" \
		meson.build || die
	grep -q "^chafa = dependency(''" meson.build || die "chafa probe not disabled"
	grep -q "^procyon = dependency(''" meson.build || die "procyon probe not disabled"

	# The duplicates plugin compares JPEG and PNG pictures when it finds
	# libjpeg or libpng and has no switch for either; USE decides instead.
	# verified 2026-11-16, src/panel-plugins/duplicates/meson.build
	local f=src/panel-plugins/duplicates/meson.build
	local jpeg="dependency($(usex jpeg "'libjpeg', required: true" "'', required: false"))"
	local png="dependency($(usex png "'libpng', required: true" "'', required: false"))"
	sed -i \
		-e "s/^dup_jpeg = dependency('libjpeg', required: false)$/dup_jpeg = ${jpeg}/" \
		-e "s/^dup_png = dependency('libpng', required: false)$/dup_png = ${png}/" \
		${f} || die
	grep -qxF "dup_jpeg = ${jpeg}" ${f} || die "libjpeg probe not pinned"
	grep -qxF "dup_png = ${png}" ${f} || die "libpng probe not pinned"
}

src_configure() {
	# GCC 15.3.1 + LTO miscompiles mctree_node_expand_to_depth (mctree_view 1/7
	# fails); GCC 16.2.0 passes. reproduced 2026-09-04 with -O2 -flto=12
	filter-lto

	local emesonargs=(
		-Dscreen=$(usex slang slang ncurses)
		# Internal-only mclib also collides with sci-libs/mc (bug #685938).
		-Dmclib=false
		-Dvfs=true
		$(meson_use edit internal_edit)
		$(meson_feature kernel_linux ext2fs_attr)
		$(meson_feature gpm)
		$(meson_feature lua)
		$(meson_feature nls)
		$(meson_feature test tests)
		$(meson_feature X x11)

		# Pin auto-detected features to USE or on, so nothing is automagic.
		-Dmagic=enabled
		-Dzlib=enabled
		-Dsession=enabled
		-Dpanel_plugin_arcmc=enabled
		# Works over an external ssh; USE=sftp only adds libssh2 password auth.
		-Dpanel_plugin_shell_link=enabled
		$(meson_feature acl panel_plugin_acl)
		$(meson_feature ftp panel_plugin_ftp)
		$(meson_feature mongodb panel_plugin_mongo)
		$(meson_feature postgres panel_plugin_postgres)
		$(meson_feature s3 panel_plugin_s3)
		$(meson_feature samba panel_plugin_samba)
		$(meson_feature sftp panel_plugin_sftp)
		$(meson_feature sftp shell_ssh2)
		$(meson_feature sqlite panel_plugin_sqlite)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# meson.build installs the Lua plugin docs to /usr/share/doc/${PN}.
	mkdir -p "${ED}/usr/share/doc/${PF}" || die
	mv "${ED}/usr/share/doc/${PN}"/* "${ED}/usr/share/doc/${PF}/" || die
	rmdir "${ED}/usr/share/doc/${PN}" || die
	einstalldocs

	# cons.saver needs setgid tty for console access (bug #334383).
	if use kernel_linux && [[ ${EUID} == 0 ]] ; then
		fowners root:tty /usr/libexec/${PN}/cons.saver
		fperms g+s /usr/libexec/${PN}/cons.saver
	fi
}

pkg_postinst() {
	optfeature "Git panel" dev-vcs/git
	optfeature "GitHub panel" dev-util/github-cli
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
	elog ". ${EPREFIX}/usr/libexec/${PN}/mc6.sh"
}
