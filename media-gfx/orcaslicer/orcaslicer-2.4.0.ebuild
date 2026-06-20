# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="OrcaSlicer"

inherit check-reqs cmake multiprocessing wxwidgets xdg

DESCRIPTION="Open-source 3D printer slicer (PrusaSlicer/Bambu Studio fork)"
HOMEPAGE="https://www.orcaslicer.com/
	https://github.com/OrcaSlicer/OrcaSlicer"
SRC_URI="https://github.com/OrcaSlicer/OrcaSlicer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="AGPL-3 Apache-2.0 Boost-1.0 GPL-2 LGPL-2.1+ LGPL-3 MIT"
SLOT="0"
# Unkeyworded: 2.4.0 hard-requires Eigen 5.0.1 (CMakeLists.txt:587,
# find_package(Eigen3 5.0.1 REQUIRED)), but the only Eigen 5 in ::gentoo
# (dev-cpp/eigen-5.0.1) is SLOT="3/5.0" -- the same main slot as the
# system Eigen 3.4, so it cannot coexist and would replace it, force-
# rebuilding every eigen:3 consumer (mantid, opencv, onnxruntime -- the
# latter deliberately vendors its own Eigen to avoid the 5.x API break).
# Keep this ebuild build-ready (patches rebased + eapply-clean) but
# unkeyworded until a coexisting/system Eigen 5 is available. verified 2026-06-20.
KEYWORDS=""
IUSE="test"

RESTRICT="!test? ( test )"

PATCHES=(
	# Unchanged from 2.3.2 (apply cleanly to 2.4.0) -- reference the original
	# files rather than per-version copies to avoid DuplicateFiles.
	"${FILESDIR}/${PN}-2.3.2-boost-1.90.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-process-v1.patch"
	"${FILESDIR}/${PN}-2.3.2-boost-asio-fs.patch"
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
)

RDEPEND="
	app-crypt/libsecret
	>=dev-cpp/eigen-5.0.1:3
	dev-cpp/nlohmann_json:=
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/libmspack
	dev-libs/libspnav
	dev-libs/mpfr:=
	media-gfx/libbgcode
	media-gfx/openvdb:=
	media-libs/draco
	media-libs/fontconfig
	media-libs/glew:0=
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

	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DORCA_TOOLS=ON
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=ON
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=OFF
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"
		-Wno-dev
	)

	cmake_src_configure
}
