# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-openvg/qt-openvg-4.8.0-r2.ebuild,v 1.1 2012/02/05 13:03:34 wired Exp $

EAPI="3"
inherit qt4-build

DESCRIPTION="Qt network bearer plugin set"
SLOT="4"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="networkmanager"

DEPEND="~x11-libs/qt-core-${PV}
	~x11-libs/qt-dbus-${PV}
	networkmanager? ( net-misc/networkmanager )
"
RDEPEND="${DEPEND}"

pkg_setup() {
	QT4_TARGET_DIRECTORIES="
		src/plugins/bearer"

	QT4_EXTRACT_DIRECTORIES="
		include/QtCore
		include/QtNetwork
		include/QtDBus
		src/corelib
		src/network
		src/plugins
		src/dbus
		src/3rdparty"

	#QCONFIG_ADD="openvg"
	#QCONFIG_DEFINE="QT_OPENVG"

	qt4-build_pkg_setup
}

src_configure() {
	myconf+="
		-no-accessibility -no-xmlpatterns -no-multimedia -no-audio-backend
-no-phonon
		-no-phonon-backend -no-svg -no-webkit -no-script -no-scripttools
-no-declarative
		-system-zlib -no-gif -no-libtiff -no-libpng -no-libmng -no-libjpeg
		-no-cups -no-gtkstyle -no-nas-sound -no-opengl
		-no-sm -no-xshape -no-xvideo -no-xsync -no-xinerama -no-xcursor
-no-xfixes
		-no-xrandr -no-xrender -no-mitshm -no-fontconfig -no-freetype -no-xinput
-no-xkb
"

	qt4-build${ECLASS}_src_configure
}

src_install() {
	qt4-build_src_install

	#touch the available graphics systems
	mkdir -p "${D}/usr/share/qt4/graphicssystems/" ||
		die "could not create ${D}/usr/share/qt4/graphicssystems/"
	echo "experimental" > "${D}/usr/share/qt4/graphicssystems/openvg" ||
		die "could not touch ${D}/usr/share/qt4/graphicssystems/openvg"
}
