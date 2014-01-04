# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python2_7 )

WX_GTK_VER="2.8"

inherit cmake-utils wxwidgets fdo-mime gnome2-utils bzr python-r1 flag-o-matic

DESCRIPTION="Electronic Schematic and PCB design tools."
HOMEPAGE="http://www.kicad-pcb.org"

LICENSE="GPL-2"
SLOT="0"
EBZR_REPO_URI="lp:kicad"
EBZR_REVISION="${PR#r}"

KEYWORDS=""

IUSE="dev-doc debug doc examples minimal python nanometr gost sexpr github"

CDEPEND="x11-libs/wxGTK:2.8[X,opengl,gnome]
		media-libs/glew"
DEPEND="${CDEPEND}
	>=dev-util/cmake-2.6.0
	>=dev-libs/boost-1.40[python?]
	app-arch/xz-utils
	dev-doc? ( app-doc/doxygen )"
RDEPEND="${CDEPEND}
	sys-libs/zlib
	sci-electronics/electronics-menu
	!minimal? ( sci-electronics/kicad-library )"

src_unpack() {
	bzr_src_unpack

	if use doc; then
		EBZR_REPO_URI="lp:~kicad-developers/kicad/doc" \
		EBZR_PROJECT="kicad-doc" \
		P="${P}/kicad-doc" \
		EBZR_CACHE_DIR="kicad-doc" \
		bzr_fetch
	fi
}

src_prepare() {
	sed 's|bzr patch -p0|patch -p0 -i|g' -i CMakeModules/download_boost.cmake

	sed -e 's/Categories=Electronics/Categories=Development;Electronics/' \
		-i	resources/linux/mime/applications/kicad.desktop || die 'sed failed'

	# Add important doc files
	sed -i -e 's/INSTALL.txt/AUTHORS.txt CHANGELOG.txt README.txt TODO.txt/' CMakeLists.txt || die "sed failed"

	# Fix desktop files
	rm resources/linux/mime/applications/eeschema.desktop

	# Handle optional minimal install
	if use minimal ; then
		sed -i -e '/add_subdirectory(template)/d' CMakeLists.txt || die "sed failed"
	fi

	# Add documentation and fix necessary code if requested
	if use doc ; then
		sed -i -e "s/subdirs.Add( wxT( \"kicad\" ) );/subdirs.Add( wxT( \"${PF}\" ) );/" \
			-e '/subdirs.Add( _T( "help" ) );/d' common/edaappl.cpp || die "sed failed"
	else
		sed -i -e '/add_subdirectory(kicad-doc)/d' CMakeLists.txt || die "sed failed"
	fi

	# Install examples in the right place if requested
	if use examples ; then
		sed -i -e 's:${KICAD_DATA}/demos:${KICAD_DOCS}/examples:' CMakeLists.txt || die "sed failed"
	else
		sed -i -e '/add_subdirectory(demos)/d' CMakeLists.txt || die "sed failed"
	fi
	sed 's|^    ../scripting/wx_python_helpers.cpp$||' -i pcbnew/CMakeLists.txt || die "sed failed"
}

src_configure() {
	bzr whoami "anonymous"
	if use amd64;then
		append-cxxflags -fPIC
	fi
	need-wxwidgets unicode

	mycmakeargs="${mycmakeargs}
		-DKICAD_DOCS=/usr/share/doc/${PF}
		-DKICAD_HELP=/usr/share/doc/${PF}
		-DKICAD_CYRILLIC=ON
		-DwxUSE_UNICODE=ON
		-DKICAD_TESTING_VERSION=ON
		-DKICAD_MINIZIP=OFF
		-DKICAD_AUIMANAGER=OFF
		-DKICAD_AUITOOLBAR=OFF
		$(cmake-utils_use gost KICAD_GOST)
		$(cmake-utils_use nanometr USE_PCBNEW_NANOMETRES)
		$(cmake-utils_use sexpr USE_PCBNEW_SEXPR_FILE_FORMAT)
		$(cmake-utils_use github BUILD_GITHUB_PLUGIN)
		$(cmake-utils_use python KICAD_SCRIPTING)
		$(cmake-utils_use python KICAD_SCRIPTING_MODULES)
		$(cmake-utils_use python KICAD_SCRIPTING_WXPYTHON)"
	cmake-utils_src_configure
}

src_compile() {
	use dev-doc && doxygen Doxyfile
}

src_install() {
	cmake-utils_src_install
	if use dev-doc ; then
		insinto /usr/share/doc/${PF}
		doins uncrustify.cfg
		cd Documentation
		doins -r GUI_Translation_HOWTO.pdf guidelines/UIpolicies.txt doxygen/*
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update

	if use minimal ; then
		ewarn "If the schematic and/or board editors complain about missing libraries when you"
		ewarn "open old projects, you will have to take one or more of the following actions :"
		ewarn "- Install the missing libraries manually."
		ewarn "- Remove the libraries from the 'Libs and Dir' preferences."
		ewarn "- Fix the libraries' locations in the 'Libs and Dir' preferences."
		ewarn "- Emerge kicad without the 'minimal' USE flag."
		elog
	fi
	elog "You may want to emerge media-gfx/wings if you want to create 3D models of components."
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
