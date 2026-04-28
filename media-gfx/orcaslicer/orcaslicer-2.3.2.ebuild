# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="OrcaSlicer"

inherit check-reqs cmake multiprocessing wxwidgets xdg

DESCRIPTION="Open-source 3D printer slicer (PrusaSlicer/Bambu Studio fork)"
HOMEPAGE="https://orcaslicer.com/
	https://github.com/SoftFever/OrcaSlicer
	https://github.com/OrcaSlicer/OrcaSlicer"
SRC_URI="https://github.com/OrcaSlicer/OrcaSlicer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="AGPL-3 Apache-2.0 Boost-1.0 GPL-2 LGPL-2.1+ LGPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${P}-boost-1.90.patch"
	"${FILESDIR}/${P}-boost-process-v1.patch"
	"${FILESDIR}/${P}-boost-asio-fs.patch"
	"${FILESDIR}/${P}-cgal-6.patch"
	"${FILESDIR}/${P}-link-webkit2gtk.patch"
	"${FILESDIR}/${P}-occt-7.8-tkdestep.patch"
	"${FILESDIR}/${P}-opencv-no-world.patch"
	"${FILESDIR}/${P}-wx-set-values-ambig.patch"
	# Silence wx assertions at runtime: upstream's bundled wx build
	# sets wxBUILD_DEBUG_LEVEL=0 (deps/wxWidgets/wxWidgets.cmake) so
	# bad sizer/widget calls never raise; system wxGTK ships with
	# wxDEBUG_LEVEL=1 and the modal assert dialog wedges startup.
	"${FILESDIR}/${P}-wx-noop-assert-handler.patch"
	# Skip g_object_set("audio-sink") when the backend lacks the
	# property: wx 3.2's media lib wraps a GstPlayer (no audio-sink
	# prop), so the unguarded call was a silent no-op that only ever
	# produced a GLib-GObject-CRITICAL on every wxMediaCtrl2 ctor.
	"${FILESDIR}/${P}-mediactrl-audio-sink-guard.patch"
)

RDEPEND="
	app-crypt/libsecret
	dev-cpp/eigen:3
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
