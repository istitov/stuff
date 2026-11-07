# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
WX_GTK_VER="3.3-gtk3"
MY_PN="OrcaSlicer"
EIGEN5_PV="5.0.1"
# Pinned by deps/SLVS/SLVS.cmake and deps/wxInspector/wxInspector.cmake.
SLVS_COMMIT="4d8704523e4bf212fadf5189f92484244f670fea"
WXINSPECTOR_PV="1.0.0"

inherit check-reqs cmake multiprocessing optfeature python-single-r1 \
	toolchain-funcs wxwidgets xdg

# Ignore old CMake declarations in unused deps/sandboxes; the configured
# top-level project requires 3.13 and sets its own CMake 4 policy floor.
CMAKE_QA_COMPAT_SKIP=1

DESCRIPTION="Open-source 3D printer slicer (PrusaSlicer/Bambu Studio fork)"
HOMEPAGE="https://www.orcaslicer.com/
	https://github.com/OrcaSlicer/OrcaSlicer"
SRC_URI="https://github.com/OrcaSlicer/OrcaSlicer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/${EIGEN5_PV}/eigen-${EIGEN5_PV}.tar.bz2
	https://github.com/JacobStoren/SolveSpaceLib/archive/${SLVS_COMMIT}.tar.gz
		-> SolveSpaceLib-${SLVS_COMMIT}.gh.tar.gz
	https://github.com/Noisyfox/wxInspector/archive/refs/tags/v${WXINSPECTOR_PV}.tar.gz
		-> wxInspector-${WXINSPECTOR_PV}.gh.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

# MPL-2.0 covers the vendored Eigen 5, GPL-3 the SolveSpace solver and
# wxWinLL-3.1 wxInspector, all compiled into the binary (src_configure).
# BSD: bundled pybind11.
LICENSE="AGPL-3 Apache-2.0 Boost-1.0 BSD GPL-2 GPL-3 LGPL-2.1+ LGPL-3 MIT MPL-2.0
	wxWinLL-3.1"
SLOT="0"
# Requires private Eigen 5 and the overlay's wxGTK 3.3 slot. verified 2026-11-07
KEYWORDS="~amd64 ~arm64"
IUSE="test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${P}-boost-1.89-system.patch.xz"
	"${FILESDIR}/${P}-boost-asio-resolver.patch.xz"
	"${FILESDIR}/${P}-boost-filesystem-copy-options.patch.xz"
	"${FILESDIR}/${P}-opencv-no-world.patch.xz"
	# System wxGTK enables assertions unlike upstream's bundled build; suppress
	# the modal assertion dialog that otherwise wedges startup.
	"${FILESDIR}/${PN}-2.3.2-wx-noop-assert-handler.patch"
	"${FILESDIR}/${PN}-2.4.1-optional-wayland.patch"
	# wxWidgets 3.3.4 renamed the grid choice editor's close-up handler.
	"${FILESDIR}/${PN}-2.4.1-wx-3.3.4-grid-editor.patch"
	# Static-link customized clipper2_z; use system md4c. Uninstalled shared
	# copies would resolve incorrectly after install-rpath stripping.
	"${FILESDIR}/${PN}-2.4.0-clipper2-static.patch"
	"${FILESDIR}/${PN}-2.4.0-md4c-system.patch"
	# Embed the system Python instead of a bundled 3.12.13 runtime, and look
	# for the system uv instead of downloading one.
	"${FILESDIR}/${P}-system-python.patch.xz"
	# The plugin sandbox only gates 3.12's thread entry point; on 3.13+
	# plugins could start threads without the Threading grant.
	"${FILESDIR}/${P}-plugin-audit-py313-threads.patch.xz"
	# Do not copy upstream's bundled FFmpeg libraries into the install.
	"${FILESDIR}/${P}-system-ffmpeg.patch.xz"
)

# OpenSSL and unbundled md4c are runtime links; customized Clipper2 is static.
# 3D-mouse support links libspnav, the shared library unless
# libspnav[static-libs] is set. TexturePainting and SkipPartCanvas decode
# PNG/JPEG through OpenCV, which returns empty images without those codecs.
# verified 2026-11-07
RDEPEND="
	${PYTHON_DEPS}
	app-crypt/libsecret
	dev-cpp/nlohmann_json:=
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/libspnav
	dev-libs/md4c
	dev-libs/mpfr:=
	dev-libs/openssl:=
	media-gfx/openvdb:=
	media-libs/assimp:=
	media-libs/draco:=
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/glfw
	media-libs/libjpeg-turbo:=
	media-libs/libnoise
	media-libs/libpng:0=
	media-libs/nanosvg:=
	media-libs/qhull:=
	media-libs/opencv:=[jpeg,png]
	media-video/ffmpeg:=
	net-libs/libdatachannel:=
	net-libs/webkit-gtk:4.1
	net-misc/curl[adns]
	sci-libs/libigl
	sci-libs/nlopt
	>=sci-libs/opencascade-8.0:=
	>=sci-mathematics/cgal-6.2:=
	sys-apps/dbus
	virtual/opengl
	virtual/zlib:=
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/pango
	x11-libs/wxGTK:${WX_GTK_VER}=[X,curl,gstreamer,keyring,opengl,webkit]
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
"
BDEPEND="
	${PYTHON_DEPS}
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
	python-single-r1_pkg_setup
}

src_prepare() {
	# 2.5.0's own patches ship xz-compressed to keep files/ under pkgcheck's
	# size limit; eapply does not decompress, so expand them into ${T}.
	local i b
	mkdir "${T}"/patches || die
	for i in "${!PATCHES[@]}"; do
		[[ ${PATCHES[i]} == *.xz ]] || continue
		b=${PATCHES[i]##*/}
		xz -dc "${PATCHES[i]}" > "${T}/patches/${b%.xz}" || die
		PATCHES[i]="${T}/patches/${b%.xz}"
	done

	# Upstream's deps tree replaces SolveSpaceLib's demo-only CMakeLists.
	cp deps/SLVS/CMakeLists.txt.in \
		"${WORKDIR}/SolveSpaceLib-${SLVS_COMMIT}/CMakeLists.txt" || die

	cmake_src_prepare
}

# Configure, build and install a bundled CMake dependency into the private
# staging prefix ${WORKDIR}/deps-root, with the target toolchain.
_orca_private_dep() {
	local src=${1} name=${2}
	shift 2
	cmake -S "${src}" -B "${WORKDIR}/${name}-build" \
		-DCMAKE_AR="$(type -P "$(tc-getAR)")" \
		-DCMAKE_RANLIB="$(type -P "$(tc-getRANLIB)")" \
		-DCMAKE_C_COMPILER="$(tc-getCC)" \
		-DCMAKE_CXX_COMPILER="$(tc-getCXX)" \
		-DCMAKE_C_FLAGS="${CPPFLAGS} ${CFLAGS}" \
		-DCMAKE_CXX_FLAGS="${CPPFLAGS} ${CXXFLAGS}" \
		-DCMAKE_BUILD_TYPE=None \
		-DCMAKE_INSTALL_PREFIX="${WORKDIR}/deps-root/usr" \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-Wno-dev "$@" || die "private ${name} configure failed"
	cmake --build "${WORKDIR}/${name}-build" -j"$(makeopts_jobs)" \
		|| die "private ${name} build failed"
	cmake --install "${WORKDIR}/${name}-build" \
		|| die "private ${name} install failed"
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	# Upstream requires Eigen 5.0.1, which shares Gentoo's main slot with 3.4.
	# Stage the header-only library privately to avoid replacing Eigen 3.4 and
	# rebuilding its consumers. libigl/CGAL instantiate against this copy.
	# verified 2026-06-20
	_orca_private_dep "${WORKDIR}/eigen-${EIGEN5_PV}" eigen5 \
		-DEIGEN_BUILD_TESTING=OFF \
		-DEIGEN_BUILD_DOC=OFF \
		-DEIGEN_BUILD_BLAS=OFF \
		-DEIGEN_BUILD_LAPACK=OFF \
		-DEIGEN_BUILD_PKGCONFIG=OFF \
		-DBUILD_TESTING=OFF
	# The Design tab's sketch solver and the wx widget inspector are fetched
	# by upstream's deps tree and linked statically; neither is packaged.
	# verified 2026-11-07
	_orca_private_dep "${WORKDIR}/SolveSpaceLib-${SLVS_COMMIT}" slvs
	_orca_private_dep "${WORKDIR}/wxInspector-${WXINSPECTOR_PV}" wxinspector \
		-DwxWidgets_CONFIG_EXECUTABLE="${WX_CONFIG}"

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
		-DCMAKE_PREFIX_PATH="${WORKDIR}/deps-root/usr"
		-DEigen3_ROOT="${WORKDIR}/deps-root/usr"
		-DORCA_SYSTEM_FFMPEG=ON
		-DORCA_SYSTEM_PYTHON=ON
		-DPython3_EXECUTABLE="${PYTHON}"
		-DORCA_SYSTEM_UV_EXECUTABLE="${EPREFIX}/usr/bin/uv"
		# Only feeds pybind11-stubgen for plugin authors; nothing installs it.
		-DORCA_BUILD_PYTHON_STUBGEN_MODULE=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_test() {
	# Known failures outside upstream's CI conditions. verified 2026-11-07
	local CMAKE_SKIP_TESTS=(
		# Needs a display.
		"JPEG texture decoding coexists with thumbnails and video frames"
		# Upstream CI skips these (RequiresApp). Here one gets profile values
		# other than it expects, and --export-3mf segfaults on a missing
		# config option in get_min_flush_volumes.
		cli_project_missing_keys
		cli_malformed_input
		# Expects the static build's OpenSSL CA override.
		"The bundled Python trusts the system CA certificates"
		# Python 3.13+ raises pathlib's glob event before the lazy listing
		# and frees frames later; both fail closed (extra prompts).
		"A saved directory walk covers each directory it lists"
		"A freshly approved operation covers its nested events"
		"A finalizer run when a root frame is let go is judged as the plugin without a prompt"
	)
	cmake_src_test
}

src_install() {
	cmake_src_install

	# The vendored header-only stb_dxt installs its header and a CMake
	# export; it is compiled into the binary and is nobody's dependency.
	rm -r "${ED}"/usr/include/stb_dxt "${ED}"/usr/lib/cmake/stb_dxt || die
	find "${ED}"/usr/include "${ED}"/usr/lib -depth -type d -empty -delete || die

	# Relocate upstream's FHS-violating /usr/LICENSE.txt.
	if [[ -f ${ED}/usr/LICENSE.txt ]]; then
		dodir /usr/share/doc/${PF}
		mv "${ED}/usr/LICENSE.txt" "${ED}/usr/share/doc/${PF}/LICENSE.txt" || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "installing Python plugin dependencies" dev-python/uv
}
