# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit cmake flag-o-matic git-r3 python-any-r1 toolchain-funcs

DESCRIPTION="Modern build tool for software projects"
HOMEPAGE="https://doc.qt.io/qbs/"
EGIT_REPO_URI="https://code.qt.io/qbs/qbs.git https://github.com/qbs/qbs.git"

LICENSE="|| ( LGPL-2.1 LGPL-3 ) Boost-1.0 BSD"
SLOT="0"
KEYWORDS=""
IUSE="doc test"
RESTRICT="!test? ( test )"

# Uses Qt CorePrivate; rebuild with qtbase subslot changes.
RDEPEND="
	dev-qt/qt5compat:6
	dev-qt/qtbase:6=[concurrent,gui,network,widgets,xml]
"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? (
		$(python_gen_any_dep '
			dev-python/beautifulsoup4[${PYTHON_USEDEP}]
			dev-python/lxml[${PYTHON_USEDEP}]
		')
		dev-qt/qttools:6[assistant,qdoc]
	)
"

CMAKE_SKIP_TESTS=(
	# QBS test projects do not inherit the CMake toolchain and fail variably with
	# clang, musl, -native-symlinks, and libc++.
	tst_api
	tst_blackbox # also skips blackbox-* (intended)
	tst_language
)

PATCHES=(
	"${FILESDIR}"/${PN}-2.3.1-qtver.patch
	"${FILESDIR}"/${PN}-2.4.1-ldconfig.patch
)

python_check_deps() {
	# Required by QbsDocumentation.cmake.
	python_has_version "dev-python/beautifulsoup4[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/lxml[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_configure() {
	# Work around Qt header macros on musl (bug 906929).
	use elibc_musl && append-lfs-flags

	# Tests fail with GCC 14+ at -O3 (bug 933187).
	use test && tc-is-gcc && [[ $(gcc-major-version) -ge 14 ]] &&
		replace-flags -O3 -O2

	local mycmakeargs=(
		-DQBS_DOC_INSTALL_DIR="${EPREFIX}"/usr/share/doc/${PF}
		-DQBS_INSTALL_HTML_DOCS=$(usex doc)
		-DQBS_INSTALL_MAN_PAGE=yes
		-DQBS_INSTALL_QCH_DOCS=$(usex doc)
		-DQBS_LIB_INSTALL_DIR="$(get_libdir)"
		-DQT_VERSION_MAJOR=6 #931596
		-DWITH_TESTS=$(usex test)
		-DWITH_UNIT_TESTS=$(usex test)
	)

	cmake_src_configure
}

src_install() {
	local DOCS=( README.md changelogs )
	cmake_src_install

	use !test || rm -- "${ED}"/usr/bin/{tst_*,qbs_*,clang-format-test} || die

	docompress -x /usr/share/doc/${PF}/qbs.qch
}
