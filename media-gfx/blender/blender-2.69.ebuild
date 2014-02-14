# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/blender-2.69.ebuild,v 1.2 2014/02/14 01:11:12 megabaks Exp $

# TODO:
#   bundled-deps: bullet is modified
#   multiple python abi?

EAPI=5
PYTHON_COMPAT=( python3_3 )
#PATCHSET="1"

inherit multilib fdo-mime gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

case ${PV} in
	*_p*)
		SRC_URI="http://dev.gentoo.org/~lu_zero/${P}.tar.gz" ;;
	*)
		SRC_URI="http://download.blender.org/source/${P}.tar.gz" ;;
esac

if [[ -n ${PATCHSET} ]]; then
	SRC_URI+=" http://dev.gentoo.org/~flameeyes/${PN}/${P}-patches-${PATCHSET}.tar.xz"
fi

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"

IUSE_MODULES="+cycles -osl openvdb +freestyle +compositor +tomato +game-engine player +addons +contrib"
IUSE_MODIFIERS="+fluid +boolean +decimate +remesh +smoke eltopo"
IUSE_CODECS="+ffmpeg openexr -jpeg2k -dds -tiff -cin -redcode quicktime"
IUSE_SYSTEM="+openmp +fftw sndfile jack +sdl -openal +nls ndof +collada -doc -debug -lzma -valgrind +buildinfo"
IUSE_GPU="-cuda -sm_20 -sm_21 -sm_30"
IUSE="+boost +bullet colorio +elbeem sse sse2 ${IUSE_MODULES} ${IUSE_MODIFIERS} ${IUSE_CODECS} ${IUSE_SYSTEM} ${IUSE_GPU}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine )
	redcode? ( ffmpeg jpeg2k )
	cycles? ( boost openexr tiff colorio )
	nls? ( boost )
	game-engine? ( boost )
	cuda? ( cycles )
	osl? ( cycles )"

RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/gflags
	dev-cpp/glog[gflags]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=media-libs/freetype-2.0
	media-libs/glew
	media-libs/libpng:0
	media-libs/libsamplerate
	sci-libs/colamd
	sci-libs/ldl
	sys-libs/zlib
	virtual/glu
	virtual/jpeg
	virtual/libintl
	virtual/opengl
	x11-libs/libXi
	x11-libs/libX11
	boost? ( >=dev-libs/boost-1.44[nls?,threads(+)] )
	collada? ( media-libs/opencollada )
	colorio? ( media-libs/opencolorio )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.2 )
	cycles? (
		media-libs/openimageio
		cuda? ( dev-util/nvidia-cuda-toolkit )
		osl? ( <media-gfx/osl-1.5 >media-gfx/osl-1.5 )
		openvdb? ( media-gfx/openvdb )
	)
	ffmpeg? (
		|| (
			media-video/ffmpeg:0[x264,mp3,encode,theora,jpeg2k?]
			>=media-video/libav-9[x264,mp3,encode,theora,jpeg2k?]
		)
	)
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openexr? ( media-libs/openexr )
	sdl? ( media-libs/libsdl[audio,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	eltopo? ( virtual/lapack )
	collada? ( media-libs/opencollada )
	quicktime? ( media-libs/libquicktime )
	lzma? ( app-arch/lzma )
	valgrind? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.1.3:3
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx
	)
	nls? ( sys-devel/gettext )"

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/01-${PN}-2.68-doxyfile.patch \
		"${FILESDIR}"/02-${PN}-2.68-unbundle-colamd.patch \
		"${FILESDIR}"/03-${PN}-2.68-remove-binreloc.patch \
		"${FILESDIR}"/04-${PN}-2.68-unbundle-glog.patch \
		"${FILESDIR}"/05-${PN}-2.68-unbundle-eigen3.patch \
		"${FILESDIR}"/06-${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/07-${PN}-2.68-sse2.patch \
		"${FILESDIR}/${PN}"-desktop.patch \
		"${FILESDIR}"/sequencer_extra_actions-3.8.patch.bz2

	# remove some bundled deps
	rm -r \
		extern/Eigen3 \
		extern/libopenjpeg \
		extern/glew \
		extern/colamd \
		extern/binreloc \
		extern/libmv/third_party/{ldl,glog,gflags} \
		|| die

	# turn off binreloc (not cached)
	sed -i \
		-e 's#set(WITH_BINRELOC ON)#set(WITH_BINRELOC OFF)#' \
		CMakeLists.txt || die

	# we don't want static glew, but it's scattered across
	# thousand files
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	sed -i \
		-e '/-DGLEW_STATIC/d' \
		$(find . -type f -name "CMakeLists.txt") || die

	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; find extern/libmv/third_party -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"

	# linguas cleanup
	local i
	if ! use nls; then
		rm -r "${S}"/release/datafiles/locale || die
	else
		if [[ -n "${LINGUAS+x}" ]] ; then
			for i in "${S}"/release/datafiles/locale/* ; do
				mylang=${i##*/}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags

	local CUDA_ARCH=""
	if use cuda; then
		if use sm_20; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_20"
			else
				CUDA_ARCH="sm_20"
			fi
		fi
		if use sm_21; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_21"
			else
				CUDA_ARCH="sm_21"
			fi
		fi
		if use sm_30; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_30"
			else
				CUDA_ARCH="sm_30"
			fi
		fi
		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs="${mycmakeargs} -DCYCLES_CUDA_ARCH=${CUDA_ARCH}"
		fi
		mycmakeargs="${mycmakeargs}
		-DWITH_CYCLES_CUDA=ON
		-DCUDA_INCLUDES=/opt/cuda/include
		-DCUDA_LIBRARIES=/opt/cuda/$(get_libdir)
		-DCUDA_NVCC=/opt/cuda/bin/nvcc"
	fi
	# WITH_PYTHON_SECURITY
	# WITH_PYTHON_SAFETY
	local mycmakeargs=(
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX=/usr
		-DWITH_INSTALL_PORTABLE=OFF
		$(cmake-utils_use_with boost BOOST)
		$(cmake-utils_use_with tomato LIBMV)
		$(cmake-utils_use_with compositor COMPOSITOR)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with collada OPENCOLLADA)
		$(cmake-utils_use_with osl CYCLES_OSL)
		$(cmake-utils_use_with osl LLVM)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with elbeem MOD_FLUID)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with fftw MOD_OCEANSIM)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with freestyle FREESTYLE)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with redcode IMAGE_OPENJPEG)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sse2 SSE2)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with colorio OPENCOLORIO)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with cin IMAGE_CINEON)
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		$(cmake-utils_use_with debug DEBUG)
		$(cmake-utils_use_with eltopo ELTOPO)
		$(cmake-utils_use_with buildinfo BUILDINFO)
		$(cmake-utils_use_with lzma LZMA)
		$(cmake-utils_use_with valgrind VALGRIND)
		$(cmake-utils_use_with quicktime QUICKTIME)
		$(cmake-utils_use_with openvdb CYCLES_OPENVDB)
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
		-DWITH_MOD_CLOTH_ELTOPO=OFF
		-DWITH_INSTALL_PORTABLE=OFF
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_test() { :; }

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "API/python"
		dohtml -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/*

		docinto "API/blender"
		dohtml -r "${CMAKE_USE_DIR}"/doc/doxygen/html/*
	fi

	# fucked up cmake will relink binary for no reason
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	dohtml "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -rf "${ED%/}"/usr/share/doc/blender

	python_fix_shebang "${ED%/}"/usr/bin/blender-thumbnailer.py
	python_optimize "${ED%/}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}
