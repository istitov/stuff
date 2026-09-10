# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 qmake-utils xdg

DESCRIPTION="Smart manager for information collecting"
HOMEPAGE="https://github.com/xintrea/mytetra_dev"
EGIT_REPO_URI="https://github.com/xintrea/${PN}_dev.git"
EGIT_BRANCH="experimental"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"

RDEPEND="
	dev-qt/qt5compat:6
	dev-qt/qtbase:6[gui,network,sql,widgets,xml]
	dev-qt/qtsvg:6
"
DEPEND="${RDEPEND}"

src_prepare() {
	xzcat "${FILESDIR}/${PN}-1.44.232-qt6.patch.xz" > "${T}/${PN}-1.44.232-qt6.patch" || die
	eapply "${T}/${PN}-1.44.232-qt6.patch"
	default
	sed -i 's|/usr/local/bin|/usr/bin|' app/app.pro || die

	# Legacy text and regex APIs require Qt5Compat under Qt 6.
	sed -i '/^greaterThan(QT_MAJOR_VERSION, 4): QT += widgets/i\
greaterThan(QT_MAJOR_VERSION, 5): QT += core5compat' \
		app/app.pro || die

	# Build pre-C99 mimetex as GNU89; GCC 14+ defaults to C23.
	sed -i '1i QMAKE_CFLAGS += -std=gnu89' thirdParty/mimetex/mimetex.pro || die

	# Avoid conflicting with glibc's strcasestr declaration.
	sed -i 's|\bstrcasestr\b|mt_strcasestr|g' \
		thirdParty/mimetex/mimetex.c || die
}

src_configure() {
	eqmake6 -recursive
}

src_compile() {
	emake -C thirdParty/mimetex -f Makefile.mimetex
	emake -C app -f Makefile.app
	emake
}

src_install() {
	emake install INSTALL_ROOT="${D}"
	einstalldocs
}
