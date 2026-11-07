# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake cuda flag-o-matic

DESCRIPTION="Development platform for CAD/CAE, 3D surface/solid modeling and data exchange"
HOMEPAGE="https://www.opencascade.com
	https://github.com/Open-Cascade-SAS/OCCT"

MY_PN="OCCT"
MY_PV="${PV//./_}"
SRC_URI="https://github.com/Open-Cascade-SAS/${MY_PN}/archive/refs/tags/V${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${MY_PV}"

LICENSE="|| ( Open-CASCADE-LGPL-2.1-Exception-1.0 LGPL-2.1 )"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64"
IUSE="X debug freeimage gles2 jemalloc json opengl optimize tbb test tk truetype vtk"

# vtk libs are hardcoded in src/Draw/TKIVtkDraw/EXTERNLIB.cmake
REQUIRED_USE="
	?? (
		optimize
		tbb
	)
	vtk? (
		X
		opengl
	)
"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-lang/tcl:=
	dev-libs/double-conversion
	tk? (
		dev-lang/tk:=
	)
	gles2? (
		media-libs/libglvnd
	)
	opengl? (
		media-libs/libglvnd[X]
	)
	X? (
		x11-libs/libX11
	)
	freeimage? (
		media-libs/freeimage
	)
	jemalloc? (
		dev-libs/jemalloc
	)
	tbb? (
		dev-cpp/tbb:=
	)
	truetype? (
		media-libs/fontconfig
		media-libs/freetype:2
	)
	vtk? (
		sci-libs/vtk:=[rendering,truetype?]
		tbb? (
			sci-libs/vtk[tbb]
		)
	)
"
DEPEND="
	${RDEPEND}
	X? (
		x11-base/xorg-proto
	)
	json? (
		dev-libs/rapidjson
	)
	test? (
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-7.9.2-0001-fix-installation-of-cmake-config-files.patch"
	"${FILESDIR}/${P}-avoid-pre-stripping-binaries.patch"
	"${FILESDIR}/${PN}-7.9.0-0004-Only-try-to-find-the-jemalloc-libs-we-are-going-to-u.patch"
	"${FILESDIR}/${PN}-7.8.0-tests.patch"
	"${FILESDIR}/${P}-posix_memalign-noexcept.patch"
	"${FILESDIR}/${P}-no-tk.patch"
	# OrcaSlicer applies this to its bundled copy; cone faces with a tilted
	# seam pcurve are otherwise left untriangulated. OCCT#572
	"${FILESDIR}/${P}-brepmesh-seam-pcurve.patch"
)

src_prepare() {
	cmake_src_prepare

	# There is an OCCT_UPDATE_TARGET_FILE cmake macro that fails due to some
	# assumptions it makes about installation paths. Rather than fixing it, just
	# get rid of the mechanism altogether - its purpose is to allow a
	# side-by-side installation of release and debug libraries.
	sed -e 's|\\${OCCT_INSTALL_BIN_LETTER}||' \
		-i adm/cmake/occt_toolkit.cmake || die
}

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/862912
	# https://tracker.dev.opencascade.org/view.php?id=33091
	filter-lto

	local mycmakeargs=(
		-D3RDPARTY_DIR="${ESYSROOT}/usr"
		-DBUILD_SOVERSION_NUMBERS=2

		-DBUILD_DOC_Overview=no
		-DBUILD_ENABLE_FPE_SIGNAL_HANDLER="$(usex debug)"
		-DBUILD_USE_PCH=no
		-DBUILD_RELEASE_DISABLE_EXCEPTIONS=no # bug #847916

		-DBUILD_GTEST="$(usex test)"

		-DINSTALL_DIR="${EPREFIX}/usr"
		-DINSTALL_DIR_BIN="$(get_libdir)/${PN}/bin"
		-DINSTALL_DIR_CMAKE="$(get_libdir)/cmake/${PN}"
		-DINSTALL_DIR_DATA="share/${PN}/data"
		-DINSTALL_DIR_DOC="share/doc/${PF}"
		-DINSTALL_DIR_INCLUDE="include/${PN}"
		-DINSTALL_DIR_LIB="$(get_libdir)/${PN}"
		-DINSTALL_DIR_RESOURCE="share/${PN}/resources"
		-DINSTALL_DIR_SCRIPT="$(get_libdir)/${PN}/bin"
		-DINSTALL_DIR_TESTS="share/${PN}/tests"
		-DINSTALL_DIR_WITH_VERSION=no
		-DINSTALL_TEST_CASES=no

		-DUSE_DRACO=no
		-DUSE_EIGEN=no
		# ffmpeg: https://tracker.dev.opencascade.org/view.php?id=32871
		-DUSE_FFMPEG=no
		-DUSE_FREEIMAGE="$(usex freeimage)"
		-DUSE_FREETYPE="$(usex truetype)"
		-DUSE_GLES2="$(usex gles2)"
		-DUSE_OPENGL="$(usex opengl)"
		# no package in tree
		-DUSE_OPENVR=no
		-DUSE_RAPIDJSON="$(usex json)"
		-DUSE_TBB="$(usex tbb)"
		-DUSE_TK="$(usex tk)"
		-DUSE_VTK="$(usex vtk)"
		-DUSE_XLIB="$(usex X)"
	)

	# Select using memory manager tool.
	if ! use jemalloc && ! use tbb; then
		mycmakeargs+=( -DUSE_MMGR_TYPE=NATIVE )
	elif use jemalloc && ! use tbb; then
		mycmakeargs+=(
			-DUSE_MMGR_TYPE=JEMALLOC
			-D3RDPARTY_JEMALLOC_INCLUDE_DIR="${ESYSROOT}/usr/include/jemalloc"
		)
	elif ! use jemalloc && use tbb; then
		mycmakeargs+=( -DUSE_MMGR_TYPE=TBB )
	elif use jemalloc && use tbb; then
		mycmakeargs+=( -DUSE_MMGR_TYPE=FLEXIBLE )
	fi

	if use test; then
		# Build the GoogleTest suite against system gtest, never a fetched copy.
		mycmakeargs+=(
			-DGTEST_USE_FETCHCONTENT=OFF
			-DINSTALL_GTEST=OFF
		)
	fi

	if use tbb; then
		mycmakeargs+=(
			-D3RDPARTY_TBB_DIR="${ESYSROOT}/usr"
		)
	fi

	if use vtk; then
		local vtk_ver
		vtk_ver="$(best_version "sci-libs/vtk")"
		vtk_ver=$(ver_cut 1-2 "${vtk_ver#sci-libs/vtk-}")
		mycmakeargs+=(
			-D3RDPARTY_VTK_INCLUDE_DIR="${ESYSROOT}/usr/include/vtk-${vtk_ver}"
			-D3RDPARTY_VTK_LIBRARY_DIR="${ESYSROOT}/usr/$(get_libdir)"
		)

		# USE=vtk depends on sci-lib/vtk, which looks up a cuda compiler when build with USE=cuda.
		# We therefore need to set the correct CUDAHOSTCXX and setup the sandbox.
		if has_version "sci-libs/vtk[cuda]"; then
			cuda_add_sandbox
			addpredict "/dev/char"
			export CUDAHOSTCXX="$(cuda_gccdir)"
		fi
	fi

	cmake_src_configure

	sed -e "s|lib/|$(get_libdir)/|" \
		-e "s|VAR_CASROOT|${EPREFIX}/usr|" \
		< "${FILESDIR}/${PN}.env.in" > "${T}/99${PN}" || die

	# use TBB for memory allocation optimizations
	if use tbb; then
		sed -e 's|^#MMGT_OPT=0$|MMGT_OPT=2|' -i "${T}/99${PN}" || die
	fi

	# use internal optimized memory manager and don't clear memory with this
	# memory manager.
	if use optimize ; then
		sed -e 's|^#MMGT_OPT=0$|MMGT_OPT=1|' \
			-e 's|^#MMGT_CLEAR=1$|MMGT_CLEAR=0|' \
			-i "${T}/99${PN}" || die
	fi
}

src_install() {
	cmake_src_install

	doenvd "${T}/99${PN}"
}
