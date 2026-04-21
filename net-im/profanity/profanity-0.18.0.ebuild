# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit meson python-single-r1

DESCRIPTION="A console based XMPP client inspired by Irssi"
HOMEPAGE="https://profanity-im.github.io"
SRC_URI="https://github.com/profanity-im/profanity/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="gpg gtk libnotify omemo omemo-qrcode otr python spellcheck test xscreensaver"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	omemo-qrcode? ( omemo )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	>=dev-db/sqlite-3.35.0:3
	>=dev-libs/glib-2.62.0:2
	>=dev-libs/libstrophe-0.12.3:=
	>=net-misc/curl-7.62.0
	sys-libs/ncurses:=[unicode(+)]
	sys-libs/readline:=
	gpg? ( app-crypt/gpgme:= )
	gtk? (
		x11-libs/gdk-pixbuf:2
		x11-libs/gtk+:3
	)
	libnotify? ( x11-libs/libnotify )
	omemo? (
		dev-libs/libgcrypt:=
		>=net-libs/libsignal-protocol-c-2.3.2
	)
	omemo-qrcode? ( media-gfx/qrencode:= )
	otr? ( >=net-libs/libotr-4.0 )
	python? ( ${PYTHON_DEPS} )
	spellcheck? ( app-text/enchant:2 )
	xscreensaver? (
		x11-libs/libX11
		x11-libs/libXScrnSaver
	)
"
DEPEND="
	${RDEPEND}
	test? ( dev-util/cmocka )
	python? (
		$(python_gen_cond_dep '
			dev-python/cython[${PYTHON_USEDEP}]
		')
	)
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Dc-plugins=enabled
		$(meson_feature gpg pgp)
		$(meson_feature gtk gdk-pixbuf)
		$(meson_feature gtk icons-and-clipboard)
		$(meson_feature libnotify notifications)
		$(meson_feature omemo)
		$(meson_feature omemo-qrcode)
		$(meson_feature otr)
		$(meson_feature python python-plugins)
		$(meson_feature spellcheck)
		$(meson_feature xscreensaver)
		-Dtests=$(usex test true false)
		-Domemo-backend=libsignal
	)

	meson_src_configure
}

pkg_postinst() {
	elog
	elog "User guide is available online:"
	elog "  https://profanity-im.github.io/userguide.html"
	elog
}
