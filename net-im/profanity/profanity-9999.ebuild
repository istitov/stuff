# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# 0.20.0 replaced the Python and C plugins with a Lua engine that uses the
# Lua 5.2+ C API (luaL_newlib, luaL_len). verified 2026-11-20
LUA_COMPAT=( lua5-{3,4} )
inherit flag-o-matic git-r3 lua-single meson xdg

DESCRIPTION="A console based XMPP client inspired by Irssi"
HOMEPAGE="https://profanity-im.github.io"
EGIT_REPO_URI="https://github.com/profanity-im/profanity.git"

LICENSE="GPL-3"
SLOT="0"
IUSE="gdk-pixbuf gpg libnotify lua omemo omemo-qrcode otr spell test tray"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	lua? ( ${LUA_REQUIRED_USE} )
	omemo-qrcode? ( omemo )
"

# Notifications and the StatusNotifierItem tray talk D-Bus through GIO, so
# neither needs a library beyond glib. verified 2026-11-20
RDEPEND="
	>=dev-db/sqlite-3.35.0:3
	>=dev-libs/glib-2.80.0:2
	>=dev-libs/libstrophe-0.12.3:=
	>=net-misc/curl-7.62.0
	sys-libs/ncurses:=[unicode(+)]
	sys-libs/readline:=
	gdk-pixbuf? ( x11-libs/gdk-pixbuf:2 )
	gpg? ( app-crypt/gpgme:= )
	lua? ( ${LUA_DEPS} )
	omemo? (
		>=dev-libs/libgcrypt-1.7.0:=
		>=net-libs/libsignal-protocol-c-2.3.2
	)
	omemo-qrcode? ( media-gfx/qrencode:= )
	otr? ( >=net-libs/libotr-4.0 )
	spell? ( app-text/enchant:2 )
"
DEPEND="
	${RDEPEND}
	test? ( dev-util/cmocka )
"
BDEPEND="virtual/pkgconfig"

pkg_setup() {
	use lua && lua-single_pkg_setup
}

src_configure() {
	# Mismatched declarations trip -Wlto-type-mismatch (bug #932874);
	# ::gentoo filters LTO too.
	filter-lto

	local emesonargs=(
		-Ddocdir="${EPREFIX}"/usr/share/doc/${PF}
		$(meson_feature gdk-pixbuf)
		$(meson_feature gpg pgp)
		$(meson_feature libnotify notifications)
		$(meson_feature lua plugins)
		$(meson_feature omemo)
		$(meson_feature omemo-qrcode)
		$(meson_feature otr)
		$(meson_feature spell spellcheck)
		$(meson_feature tray)
		-Dinstall_desktop=true
		-Dtests=$(usex test true false)
		-Domemo-backend=libsignal
	)
	use lua && emesonargs+=( -Dlua-version="${ELUA}" )

	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst

	elog
	elog "User guide is available online:"
	elog "  https://profanity-im.github.io/userguide.html"
	elog
	elog "0.20.0 removed Python and C plugins in favour of Lua (USE=lua),"
	elog "and replaced the GTK tray, clipboard paste and XScreenSaver idle"
	elog "detection with a D-Bus StatusNotifierItem tray (USE=tray)."
}
