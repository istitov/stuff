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
	bzcat "${FILESDIR}/${PN}-1.44.232-qt6.patch.bz2" > "${T}/${PN}-1.44.232-qt6.patch" || die
	eapply "${T}/${PN}-1.44.232-qt6.patch"
	default
	sed -i 's|/usr/local/bin|/usr/bin|' app/app.pro || die

	# Qt6: upstream still uses QTextCodec, QRegExp etc. which live in Qt5Compat.
	sed -i '/^greaterThan(QT_MAJOR_VERSION, 4): QT += widgets/i\
greaterThan(QT_MAJOR_VERSION, 5): QT += core5compat' \
		app/app.pro || die

	# mimetex.c is pre-C99 and fails to build with GCC 14+ which defaults to
	# -std=c23. Force an older C standard for the mimetex subproject only.
	sed -i '1i QMAKE_CFLAGS += -std=gnu89' thirdParty/mimetex/mimetex.pro || die

	# mimetex defines its own strcasestr with a signature that conflicts with
	# glibc's. Rename the local copy.
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
