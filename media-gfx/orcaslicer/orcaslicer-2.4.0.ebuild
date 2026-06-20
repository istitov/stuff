# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.3-gtk3"
MY_PN="OrcaSlicer"
# Vendored Eigen: 2.4.0 hard-requires Eigen 5, which shares main SLOT 3 with
# the system Eigen 3.4 and cannot coexist -- prestaged + privately installed
# in src_configure rather than depended on. See the eigen block there.
EIGEN5_PV="5.0.1"

inherit check-reqs cmake multiprocessing wxwidgets xdg

DESCRIPTION="Open-source 3D printer slicer (PrusaSlicer/Bambu Studio fork)"
HOMEPAGE="https://www.orcaslicer.com/
	https://github.com/OrcaSlicer/OrcaSlicer"
SRC_URI="https://github.com/OrcaSlicer/OrcaSlicer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN5_PV}/eigen-${EIGEN5_PV}.tar.bz2"

S="${WORKDIR}/${MY_PN}-${PV}"

# MPL-2.0 covers the vendored Eigen 5 compiled into the binary (src_configure).
LICENSE="AGPL-3 Apache-2.0 Boost-1.0 GPL-2 LGPL-2.1+ LGPL-3 MIT MPL-2.0"
SLOT="0"
# 2.4.0 needs two things ::gentoo doesn't provide for this consumer: Eigen 5
# (shares eigen:3's main slot, so it can't be a normal dep -- vendored in
# src_configure) and wxWidgets >=3.3 (src/CMakeLists.txt:34, no wxGTK 3.3 slot
# in ::gentoo -- provided by ::stuff's x11-libs/wxGTK-3.3.* slot + forked
# wxwidgets.eclass, selected via WX_GTK_VER=3.3-gtk3 above). verified 2026-06-20.
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

PATCHES=(
	# Unchanged from 2.3.2 (apply cleanly to 2.4.0) -- reference the original
	# files rather than per-version copies to avoid DuplicateFiles.
	"${FILESDIR}/${PN}-2.3.2-boost-1.90.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-process-v1.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-asio-fs.patch"
	# New in 2.4.0: reserve_loopback_port() still uses the removed
	# boost::asio::io_service type; switch it to io_context (Boost 1.87+).
	"${FILESDIR}/${P}-boost-asio-io_context.patch"
	"${FILESDIR}/${PN}-2.3.2-cgal-6.patch"
	"${FILESDIR}/${PN}-2.3.2-occt-7.8-tkdestep.patch"
	"${FILESDIR}/${PN}-2.3.2-opencv-no-world.patch"
	# wx-set-values-ambig dropped for 2.4.0: upstream already ships
	# set_values(std::vector<std::string>{...}) at PhysicalPrinterDialog.cpp.
	# Silence wx assertions at runtime: upstream's bundled wx build
	# sets wxBUILD_DEBUG_LEVEL=0 (deps/wxWidgets/wxWidgets.cmake) so
	# bad sizer/widget calls never raise; system wxGTK ships with
	# wxDEBUG_LEVEL=1 and the modal assert dialog wedges startup.
	"${FILESDIR}/${PN}-2.3.2-wx-noop-assert-handler.patch"
	# Rebased for 2.4.0 (upstream context shifted): force unconditional
	# X11/webkit2gtk linking (was FLATPAK-only), and guard the
	# g_object_set("audio-sink") with g_object_class_find_property.
	"${FILESDIR}/${P}-link-webkit2gtk.patch"
	"${FILESDIR}/${P}-mediactrl-audio-sink-guard.patch"
	# Static-link the customized vendored Clipper2 (no system equivalent -- it
	# ships a bespoke clipper2_z Z-coordinate variant), and build md4c against
	# the system lib instead of the vendored copy. Both otherwise build shared
	# but uninstalled, resolving to system libs after the install rpath strip.
	"${FILESDIR}/${P}-clipper2-static.patch"
	"${FILESDIR}/${P}-md4c-system.patch"
)

# orca-slicer links OpenSSL (OpenSSL::SSL/Crypto via find_package) and the
# system md4c (the vendored md4c is unbundled to the system lib by the
# md4c-system patch) -- both real build+runtime deps. The vendored clipper2 is
# static-linked instead (clipper2-static patch; it ships a customized clipper2_z
# variant the system lib lacks), so it is baked in and is NOT a dependency.
# libspnav is build-time only -- the 3D-mouse support links it statically
# (CMakeLists find_library libspnav.a) -- so it lives in DEPEND, not RDEPEND.
# verified 2026-06-20.
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
		# Several CGAL/Eigen-heavy translation units (CutSurface, MeshBoolean,
		# Arrange, BuildVolume, ...) peak around 4-5 GiB of resident RAM each
		# while cc1plus instantiates templates. Scale the requirement with
		# MAKEOPTS jobs so the merge fails up front instead of getting OOM
		# killed mid-link.
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
	# Replace +UNKNOWN suffix with overlay tag (upstream's build_linux.sh sets
	# this to a date; we use a stable identifier instead).
	sed -i -e "s/+UNKNOWN/_Gentoo/" version.inc || die

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	# Vendored Eigen 5 (header-only). 2.4.0 hard-requires Eigen 5.0.1
	# (find_package(Eigen3 5.0.1 REQUIRED) at CMakeLists.txt:1044), but
	# ::gentoo's dev-cpp/eigen-5.0.1 is SLOT="3/5.0" -- the same main slot as
	# the system Eigen 3.4 -- so it cannot be installed alongside without
	# replacing it and force-rebuilding every eigen:3 consumer (cgal, libigl,
	# opencv, ...). Instead configure+install a private Eigen 5 into the work
	# dir and point find_package at it (the onnxruntime vendoring pattern),
	# leaving the system eigen:3 untouched. Eigen is header-only, so the
	# "install" is just headers + the generated Eigen3Config.cmake. orcaslicer
	# and the header-only libigl/CGAL templates it pulls all instantiate against
	# this private Eigen 5. verified 2026-06-20.
	local eigen5_root="${WORKDIR}/eigen5-root"
	cmake -S "${WORKDIR}/eigen-${EIGEN5_PV}" -B "${WORKDIR}/eigen5-build" \
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
		# Resolve find_package(Eigen3 5.0.1) to the vendored copy above; it is
		# searched ahead of the system prefix, so the system eigen-3.4 config
		# (which fails the 5.0.1 version check anyway) is never selected.
		-DCMAKE_PREFIX_PATH="${eigen5_root}/usr"
		-DEigen3_ROOT="${eigen5_root}/usr"
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Upstream's CMake installs LICENSE.txt at the install-prefix root
	# (/usr/LICENSE.txt), which trips the FHS/Gentoo-policy QA check. Relocate
	# it to the standard per-package docs directory.
	if [[ -f ${ED}/usr/LICENSE.txt ]]; then
		dodir /usr/share/doc/${PF}
		mv "${ED}/usr/LICENSE.txt" "${ED}/usr/share/doc/${PF}/LICENSE.txt" || die
	fi
}
