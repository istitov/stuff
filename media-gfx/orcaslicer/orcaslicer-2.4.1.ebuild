# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.3-gtk3"
MY_PN="OrcaSlicer"
EIGEN5_PV="5.0.1"

inherit check-reqs cmake multiprocessing toolchain-funcs wxwidgets xdg

# Ignore old CMake declarations in unused deps/sandboxes; the configured
# top-level project requires 3.13 and sets its own CMake 4 policy floor.
CMAKE_QA_COMPAT_SKIP=1

DESCRIPTION="Open-source 3D printer slicer (PrusaSlicer/Bambu Studio fork)"
HOMEPAGE="https://www.orcaslicer.com/
	https://github.com/OrcaSlicer/OrcaSlicer"
SRC_URI="https://github.com/OrcaSlicer/OrcaSlicer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN5_PV}/eigen-${EIGEN5_PV}.tar.bz2"

S="${WORKDIR}/${MY_PN}-${PV}"

# MPL-2.0 covers the vendored Eigen 5 compiled into the binary (src_configure).
LICENSE="AGPL-3 Apache-2.0 Boost-1.0 GPL-2 LGPL-2.1+ LGPL-3 MIT MPL-2.0"
SLOT="0"
# Requires private Eigen 5 and the overlay's wxGTK 3.3 slot. verified 2026-06-20
KEYWORDS="~amd64 ~arm64"
IUSE="test"

RESTRICT="!test? ( test )"

PATCHES=(
	# Reuse matching older patches rather than create DuplicateFiles copies.
	"${FILESDIR}/${PN}-2.3.2-boost-1.90.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-process-v1.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-asio-fs.patch"
	# Replace removed boost::asio::io_service with io_context for Boost 1.87+.
	"${FILESDIR}/${PN}-2.4.0-boost-asio-io_context.patch"
	"${FILESDIR}/${PN}-2.3.2-cgal-6.patch"
	"${FILESDIR}/${PN}-2.3.2-occt-7.8-tkdestep.patch"
	"${FILESDIR}/${PN}-2.3.2-opencv-no-world.patch"
	# System wxGTK enables assertions unlike upstream's bundled build; suppress
	# the modal assertion dialog that otherwise wedges startup.
	"${FILESDIR}/${PN}-2.3.2-wx-noop-assert-handler.patch"
	# Link X11/webkit2gtk outside Flatpak and guard the optional audio-sink property.
	"${FILESDIR}/${PN}-2.4.0-link-webkit2gtk.patch"
	"${FILESDIR}/${PN}-2.4.0-mediactrl-audio-sink-guard.patch"
	"${FILESDIR}/${PN}-2.4.1-optional-wayland.patch"
	# Static-link customized clipper2_z; use system md4c. Uninstalled shared
	# copies would resolve incorrectly after install-rpath stripping.
	"${FILESDIR}/${PN}-2.4.0-clipper2-static.patch"
	"${FILESDIR}/${PN}-2.4.0-md4c-system.patch"
)

# OpenSSL and unbundled md4c are runtime links; customized Clipper2 is static.
# libspnav is build-only because 3D-mouse support links libspnav.a.
# verified 2026-06-20
RDEPEND="
	app-crypt/libsecret
	dev-cpp/nlohmann_json:=
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/md4c
	dev-libs/mpfr:=
	dev-libs/openssl:=
	media-gfx/openvdb:=
	media-libs/draco
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/glfw
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/libjpeg-turbo:=
	media-libs/libnoise
	media-libs/libpng:0=
	media-libs/nanosvg:=
	media-libs/qhull:=
	media-libs/opencv:=
	net-libs/webkit-gtk:4.1
	net-misc/curl[adns]
	sci-libs/libigl
	sci-libs/nlopt
	sci-libs/opencascade:=
	sci-mathematics/cgal:=
	sys-apps/dbus
	virtual/opengl
	virtual/zlib:=
	x11-libs/gtk+:3
	x11-libs/wxGTK:${WX_GTK_VER}=[X,curl,gstreamer,keyring,opengl,webkit]
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
	dev-libs/libspnav
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		# CGAL/Eigen translation units use 4-5 GiB each; scale with MAKEOPTS to
		# reject likely OOM builds before compilation.
		local jobs
		jobs=$(makeopts_jobs)
		local CHECKREQS_DISK_BUILD="12G"
		local CHECKREQS_MEMORY="$((jobs * 4 + 2))G"
		check-reqs_pkg_pretend
		if (( jobs > 4 )); then
			ewarn "MAKEOPTS=\"-j${jobs}\" will instantiate many heavy CGAL/Eigen"
			ewarn "translation units in parallel. If cc1plus gets OOM-killed,"
			ewarn "drop to -j4 via /etc/portage/env/${CATEGORY}/${PN}."
		fi
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		local jobs
		jobs=$(makeopts_jobs)
		local CHECKREQS_DISK_BUILD="12G"
		local CHECKREQS_MEMORY="$((jobs * 4 + 2))G"
		check-reqs_pkg_setup
	fi
}

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	# Upstream requires Eigen 5.0.1, which shares Gentoo's main slot with 3.4.
	# Stage the header-only library privately to avoid replacing Eigen 3.4 and
	# rebuilding its consumers. libigl/CGAL instantiate against this copy.
	# verified 2026-06-20
	local eigen5_root="${WORKDIR}/eigen5-root"
	# Keep cross-distcc on the target compiler.
	cmake -S "${WORKDIR}/eigen-${EIGEN5_PV}" -B "${WORKDIR}/eigen5-build" \
		-DCMAKE_C_COMPILER="$(tc-getCC)" \
		-DCMAKE_CXX_COMPILER="$(tc-getCXX)" \
		-DCMAKE_INSTALL_PREFIX="${eigen5_root}/usr" \
		-DEIGEN_BUILD_TESTING=OFF \
		-DEIGEN_BUILD_DOC=OFF \
		-DEIGEN_BUILD_BLAS=OFF \
		-DEIGEN_BUILD_LAPACK=OFF \
		-DEIGEN_BUILD_PKGCONFIG=OFF \
		-DBUILD_TESTING=OFF \
		-Wno-dev || die "private Eigen 5 configure failed"
	cmake --install "${WORKDIR}/eigen5-build" || die "private Eigen 5 install failed"

	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DORCA_TOOLS=ON
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=ON
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=OFF
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		# Resolve Eigen before the incompatible system-3.4 config.
		-DCMAKE_PREFIX_PATH="${eigen5_root}/usr"
		-DEigen3_ROOT="${eigen5_root}/usr"
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Relocate upstream's FHS-violating /usr/LICENSE.txt.
	if [[ -f ${ED}/usr/LICENSE.txt ]]; then
		dodir /usr/share/doc/${PF}
		mv "${ED}/usr/LICENSE.txt" "${ED}/usr/share/doc/${PF}/LICENSE.txt" || die
	fi
}
