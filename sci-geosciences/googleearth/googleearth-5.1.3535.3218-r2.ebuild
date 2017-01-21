# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils unpacker fdo-mime versionator toolchain-funcs

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="http://earth.google.com/"
# no upstream versioning, version determined from help/about
# incorrect digest means upstream bumped and thus needs version bump
SRC_URI="https://dl.dropboxusercontent.com/u/9454972/GoogleEarthLinux-${PV}.bin"

LICENSE="googleearth GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip"
IUSE="mdns-bundled qt-bundled"

GCC_NEEDED="4.2"

RDEPEND="|| ( >=sys-devel/gcc-${GCC_NEEDED}[cxx] >=sys-devel/gcc-${GCC_NEEDED}[-nocxx] )
	x86? (
		media-libs/fontconfig
		media-libs/freetype
		virtual/opengl
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXext
		x11-libs/libXrender
		x11-libs/libXau
		x11-libs/libXdmcp
		sys-libs/zlib
		dev-libs/glib:2
		!qt-bundled? (
			dev-qt/qtcore:4
			dev-qt/qtgui:4
			dev-qt/qtwebkit:4
		)
		net-misc/curl
		sci-libs/gdal
		!mdns-bundled? ( sys-auth/nss-mdns )
	)
	amd64? (
		media-libs/fontconfig[abi_x86_32]
		media-libs/freetype[abi_x86_32]
		x11-libs/libICE[abi_x86_32]
		x11-libs/libSM[abi_x86_32]
		x11-libs/libX11[abi_x86_32]
		x11-libs/libXScrnSaver[abi_x86_32]
		x11-libs/libXau[abi_x86_32]
		x11-libs/libXaw[abi_x86_32]
		x11-libs/libXcomposite[abi_x86_32]
		x11-libs/libXcursor[abi_x86_32]
		x11-libs/libXdamage[abi_x86_32]
		x11-libs/libXdmcp[abi_x86_32]
		x11-libs/libXext[abi_x86_32]
		x11-libs/libXfixes[abi_x86_32]
		x11-libs/libXft[abi_x86_32]
		x11-libs/libXi[abi_x86_32]
		x11-libs/libXinerama[abi_x86_32]
		x11-libs/libXmu[abi_x86_32]
		x11-libs/libXp[abi_x86_32]
		x11-libs/libXpm[abi_x86_32]
		x11-libs/libXrandr[abi_x86_32]
		x11-libs/libXrender[abi_x86_32]
		x11-libs/libXt[abi_x86_32]
		x11-libs/libXtst[abi_x86_32]
		x11-libs/libXv[abi_x86_32]
		x11-libs/libXvMC[abi_x86_32]
		x11-libs/libXxf86dga[abi_x86_32]
		x11-libs/libXxf86vm[abi_x86_32]
		x11-libs/libpciaccess[abi_x86_32]
		x11-libs/libvdpau[abi_x86_32]
		x11-libs/libxcb[abi_x86_32]
		x11-proto/scrnsaverproto[abi_x86_32]
		media-libs/freeglut[abi_x86_32]
		media-libs/glew[abi_x86_32]
		media-libs/glu[abi_x86_32]
		media-libs/mesa[abi_x86_32]
		x11-libs/libdrm[abi_x86_32]
		!qt-bundled? (
			dev-qt/qtxmlpatterns[abi_x86_32]
			dev-qt/qtwebkit[abi_x86_32]
			dev-qt/qttranslations[abi_x86_32]
			dev-qt/qttest[abi_x86_32]
			dev-qt/qtsvg[abi_x86_32]
			dev-qt/qtsql[abi_x86_32]
			dev-qt/qtscript[abi_x86_32]
			dev-qt/qtopengl[abi_x86_32]
			dev-qt/qthelp[abi_x86_32]
			dev-qt/qtgui[abi_x86_32]
			dev-qt/qtdeclarative[abi_x86_32]
			dev-qt/qtdbus[abi_x86_32]
			dev-qt/qtcore[abi_x86_32]
			dev-qt/qt3support[abi_x86_32]
			dev-qt/designer
		)
	)
	virtual/ttf-fonts"

S="${WORKDIR}"

QA_TEXTRELS="opt/googleearth/libgps.so
opt/googleearth/libgooglesearch.so
opt/googleearth/libevll.so
opt/googleearth/librender.so
opt/googleearth/libinput_plugin.so
opt/googleearth/libflightsim.so
opt/googleearth/libcollada.so
opt/googleearth/libminizip.so
opt/googleearth/libauth.so
opt/googleearth/libbasicingest.so
opt/googleearth/libmeasure.so
opt/googleearth/libgoogleearth_lib.so
opt/googleearth/libmoduleframework.so
"

QA_FLAGS_IGNORED="opt/${PN}/.*"

pkg_setup() {
	GCC_VER="$(gcc-version)"
	if ! version_is_at_least ${GCC_NEEDED} ${GCC_VER}; then
		ewarn "${PN} needs libraries from gcc-${GCC_NEEDED} or higher to run"
		ewarn "Your active gcc version is only ${GCC_VER}"
		ewarn "Please consult the GCC upgrade guide to set a higher version:"
		ewarn "http://www.gentoo.org/doc/en/gcc-upgrading.xml"
	fi
}

src_unpack() {
	unpack_makeself

	cd "${WORKDIR}"/bin || die
	unpack ./../${PN}-linux-x86.tar

	mkdir "${WORKDIR}"/data && cd "${WORKDIR}"/data || die
	unpack ./../${PN}-data.tar

	cd "${WORKDIR}"/bin || die

	if ! use qt-bundled; then
		rm -v libQt{Core,Gui,Network,WebKit}.so.4 ../data/qt.conf || die
		rm -frv ../data/plugins/imageformats || die
	fi
	rm -v libGLU.so.1 libcurl.so.4 || die
	if ! use mdns-bundled; then
		rm -v libnss_mdns4_minimal.so.2 || die
	fi

	if use x86; then
		# no 32 bit libs for gdal
		rm -v libgdal.so.1 || die
	fi
}

src_prepare() {
	cd "${WORKDIR}"/bin || die
	# bug #262780
	epatch "${FILESDIR}/decimal-separator.patch"

	# make the postinst script only create the files; it's  installation
	# are too complicated and inserting them ourselves is easier than
	# hacking around it
	sed -i -e 's:$SETUP_INSTALLPATH/::' \
		-e 's:$SETUP_INSTALLPATH:1:' \
		-e "s:^xdg-desktop-icon.*$::" \
		-e "s:^xdg-desktop-menu.*$::" \
		-e "s:^xdg-mime.*$::" "${WORKDIR}"/postinstall.sh || die
}

src_install() {
	make_wrapper ${PN} ./${PN} /opt/${PN} . || die "make_wrapper failed"
	./postinstall.sh
	insinto /usr/share/mime/packages
	doins ${PN}-mimetypes.xml || die
	domenu Google-${PN}.desktop || die
	doicon ${PN}-icon.png || die
	dodoc README.linux || die

	cd bin || die
	exeinto /opt/${PN}
	doexe * || die

	cp -pPR "${WORKDIR}"/data/* "${D}"/opt/${PN} || die
	fowners -R root:root /opt/${PN}
	fperms -R a-x,a+X /opt/googleearth/resources
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_nofetch() {
	elog "This version is no longer available from Google and the license prevents mirroring."
	elog "This ebuild is intended for users who already downloaded it previously and have problems with 5.2+."
	elog "If you can get the distfile from e.g. another computer of yours,"
	elog "copy the file ${SRC_URI} to ${DISTDIR}."
	elog "Otherwise, you need to unmask 5.2 or higher version."
#	elog "stabilization is tracked at https://bugs.gentoo.org/show_bug.cgi?id=320065"
}
