# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )

inherit cmake-utils python-r1 virtualx

DESCRIPTION="Python bindings for the Qt framework"
HOMEPAGE="https://wiki.qt.io/Qt_for_Python"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://code.qt.io/pyside/pyside-setup.git"
	EGIT_BRANCH="5.9"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-${PV}-src/${PN}-setup-everywhere-src-${PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

# See "sources/pyside2/PySide2/licensecomment.txt" for licensing details.
LICENSE="|| ( GPL-2 GPL-3+ LGPL-3 )"
SLOT="2"

# TODO: webkit
# Essential: core gui widgets printsupport sql network testlib concurrent
#	x11extras
# Optional: 3d location positioning scxml sensors
# Shouldn't the essential modules be removed from IUSE? Some optional
# modules aren't handled yet in IUSE (see above), shouldn't we add them?
IUSE="3d charts concurrent datavis declarative designer +gui help location
	multimedia network opengl positioning printsupport script scripttools
	scxml sensors speech sql svg test testlib webchannel webengine
	websockets +widgets x11extras xmlpatterns"

# The requirements below were extracted from the output of
# 'grep "set(.*_deps" "${S}"/PySide2/Qt*/CMakeLists.txt'
#	webkit? ( gui network printsupport widgets )
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	3d? ( gui network )
	charts? ( widgets )
	datavis? ( gui )
	declarative? ( gui network )
	designer? ( widgets )
	help? ( widgets )
	location? ( positioning )
	multimedia? ( gui network )
	opengl? ( widgets )
	printsupport? ( widgets )
	scripttools? ( gui script widgets )
	speech? ( multimedia )
	sql? ( widgets )
	svg? ( widgets )
	testlib? ( widgets )
	webengine? ( gui network webchannel widgets )
	websockets? ( network )
	widgets? ( gui )
	x11extras? ( gui )
"

#	webkit? ( dev-qt/qtwebkit:5=[printsupport] )
DEPEND="
	${PYTHON_DEPS}
	~dev-python/shiboken-${PV}:${SLOT}[${PYTHON_USEDEP}]
	>=dev-qt/qtcore-${PV}:5
	>=dev-qt/qtxml-${PV}:5
	3d? ( >=dev-qt/qt3d-${PV}:5 )
	charts? ( >=dev-qt/qtcharts-${PV}:5 )
	concurrent? ( >=dev-qt/qtconcurrent-${PV}:5 )
	datavis? ( >=dev-qt/qtdatavis3d-${PV}:5 )
	declarative? ( >=dev-qt/qtdeclarative-${PV}:5[widgets?] )
	designer? ( >=dev-qt/designer-${PV}:5 )
	gui? ( >=dev-qt/qtgui-${PV}:5 )
	help? ( >=dev-qt/qthelp-${PV}:5 )
	location? ( >=dev-qt/qtlocation-${PV}:5 )
	multimedia? ( >=dev-qt/qtmultimedia-${PV}:5[widgets?] )
	network? ( >=dev-qt/qtnetwork-${PV}:5 )
	opengl? ( >=dev-qt/qtopengl-${PV}:5 )
	positioning? ( >=dev-qt/qtpositioning-${PV}:5 )
	printsupport? ( >=dev-qt/qtprintsupport-${PV}:5 )
	script? ( >=dev-qt/qtscript-${PV}:5 )
	scxml? ( >=dev-qt/qtscxml-${PV}:5 )
	sensors? ( >=dev-qt/qtsensors-${PV}:5 )
	speech? ( >=dev-qt/qtspeech-${PV}:5 )
	sql? ( >=dev-qt/qtsql-${PV}:5 )
	svg? ( >=dev-qt/qtsvg-${PV}:5 )
	testlib? ( >=dev-qt/qttest-${PV}:5 )
	webchannel? ( >=dev-qt/qtwebchannel-${PV}:5 )
	webengine? ( >=dev-qt/qtwebengine-${PV}:5[widgets] )
	websockets? ( >=dev-qt/qtwebsockets-${PV}:5 )
	widgets? ( >=dev-qt/qtwidgets-${PV}:5 )
	x11extras? ( >=dev-qt/qtx11extras-${PV}:5 )
	xmlpatterns? ( >=dev-qt/qtxmlpatterns-${PV}:5 )
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-setup-everywhere-src-${PV}/sources/pyside2

#PATCHES=( "${FILESDIR}/${P}-enable-webkit.patch" )

src_prepare() {
	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

#		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebKit=$(usex !webkit)
#		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebKitWidgets=$(usex !webkit)
src_configure() {
	# See COLLECT_MODULE_IF_FOUND macros in CMakeLists.txt
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DAnimation=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DCore=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DExtras=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DInput=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DLogic=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt53DRender=$(usex !3d)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Charts=$(usex !charts)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Concurrent=$(usex !concurrent)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5DataVisualization=$(usex !datavis)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Designer=$(usex !designer)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Gui=$(usex !gui)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Help=$(usex !help)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Location=$(usex !location)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Multimedia=$(usex !multimedia)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5MultimediaWidgets=$(usex !multimedia yes $(usex !widgets))
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Network=$(usex !network)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5OpenGL=$(usex !opengl)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Positioning=$(usex !positioning)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5PrintSupport=$(usex !printsupport)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Qml=$(usex !declarative)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Quick=$(usex !declarative)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5QuickWidgets=$(usex !declarative yes $(usex !widgets))
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Script=$(usex !script)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5ScriptTools=$(usex !scripttools)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Scxml=$(usex !scxml)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Sensors=$(usex !sensors)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Sql=$(usex !sql)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Svg=$(usex !svg)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Test=$(usex !testlib)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5TextToSpeech=$(usex !speech)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5UiTools=$(usex !designer)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebChannel=$(usex !webchannel)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebEngine=$(usex !webengine)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebEngineCore=$(usex !webengine)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebEngineWidgets=$(usex !webengine)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5WebSockets=$(usex !websockets)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Widgets=$(usex !widgets)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5X11Extras=$(usex !x11extras)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5XmlPatterns=$(usex !xmlpatterns)
	)

	configuration() {
		local mycmakeargs=(
			"${mycmakeargs[@]}"
			-DPYTHON_EXECUTABLE="${PYTHON}"
		)
		cmake-utils_src_configure
	}
	python_foreach_impl configuration
}

src_compile() {
	python_foreach_impl cmake-utils_src_compile
}

src_test() {
	local -x PYTHONDONTWRITEBYTECODE
	python_foreach_impl virtx cmake-utils_src_test
}

src_install() {
	installation() {
		cmake-utils_src_install
		mv "${ED%/}"/usr/$(get_libdir)/pkgconfig/${PN}2{,-${EPYTHON}}.pc || die
	}
	python_foreach_impl installation
}
