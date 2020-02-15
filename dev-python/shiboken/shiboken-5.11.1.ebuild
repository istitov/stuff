# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7} )

inherit cmake llvm python-r1

DESCRIPTION="Tool for creating Python bindings for C++ libraries"
HOMEPAGE="https://wiki.qt.io/PySide2"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://code.qt.io/pyside/pyside-setup.git"
	EGIT_BRANCH="5.9"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-${PV}-src/pyside-setup-everywhere-src-${PV}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

# The "sources/shiboken2/libshiboken" directory is triple-licensed under the GPL
# v2, v3+, and LGPL v3. All remaining files are licensed under the GPL v3 with
# version 1.0 of a Qt-specific exception enabling shiboken2 output to be
# arbitrarily relicensed. (TODO)
LICENSE="|| ( GPL-2 GPL-3+ LGPL-3 ) GPL-3"
SLOT="2"

IUSE="numpy test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Minimum version of Qt required.
QT_PV="5.9.0:5"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-qt/qtcore-${QT_PV}
	>=dev-qt/qtxml-${QT_PV}
	>=dev-qt/qtxmlpatterns-${QT_PV}
	>=sys-devel/clang-3.9.1:=
	numpy? ( dev-python/numpy )
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/pyside-setup-everywhere-src-${PV}/sources/shiboken2

DOCS=( AUTHORS )

PATCHES=(
	"${FILESDIR}"/${P}-fix-clang-include-path.patch
	"${FILESDIR}"/${P}-fix-warnings.patch
	"${FILESDIR}"/${P}-include-QStringList.patch
)

# Ensure the path returned by get_llvm_prefix() contains clang as well.
llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
}

src_prepare() {
	#FIXME: File an upstream issue requesting a sane way to disable NumPy support.
	if ! use numpy; then
		sed -i -e '/print(os\.path\.realpath(numpy))/d' libshiboken/CMakeLists.txt || die
	fi

	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi

#	eapply "${FILESDIR}"/${P}-fix-warnings.patch

	cmake_src_prepare
}

src_configure() {
	configuration() {
		local mycmakeargs=(
			-DBUILD_TESTS=$(usex test)
			-DPYTHON_EXECUTABLE="${PYTHON}"
			-DPYTHON_SITE_PACKAGES="$(python_get_sitedir)"
		)
		cmake_src_configure
	}
	python_foreach_impl configuration
}

src_compile() {
	python_foreach_impl cmake_src_compile
}

src_test() {
	python_foreach_impl cmake_src_test
}

src_install() {
	installation() {
		cmake_src_install
		mv "${ED%/}"/usr/$(get_libdir)/pkgconfig/${PN}2{,-${EPYTHON}}.pc || die
	}
	python_foreach_impl installation
}
