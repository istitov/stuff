# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/blender-2.72-r1.ebuild,v 1.1 2014/09/27 15:03:38 hasufell Exp $

EAPI=5
PYTHON_COMPAT=( python3_4 )

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

IUSE_MODULES="+ceres +cycles +openimageio +colorio -osl openvdb +freestyle +compositor +tomato +game-engine player +contrib +X"
IUSE_MODIFIERS="+bullet +fluid +boolean +decimate +remesh +smoke +oceansim eltopo"
IUSE_CODECS="+ffmpeg openexr -jpeg2k -dds -tiff -cin -redcode quicktime"
IUSE_SYSTEM="+boost +opennl +openmp sse +sse2 +fftw sndfile jack +sdl -openal +nls ndof +collada -doc -debug -lzma -valgrind +buildinfo"
IUSE_GPU="-cuda -sm_20 -sm_21 -sm_30 -sm_35"
IUSE="${IUSE_MODULES} ${IUSE_MODIFIERS} ${IUSE_CODECS} ${IUSE_SYSTEM} ${IUSE_GPU}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine )
	redcode? ( jpeg2k ffmpeg )
	cycles? ( boost openexr tiff )
	nls? ( boost )
	game-engine? ( boost )"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-cpp/gflags-2.1.1-r1
	>=dev-cpp/glog-0.3.3-r1[gflags]
	>=dev-libs/lzo-2.08:2
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
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
	colorio? ( >=media-libs/opencolorio-1.0.9 )
	cycles? (
		media-libs/openimageio
	)
	ffmpeg? (
		|| (
			>=media-video/ffmpeg-2.2:0[x264,mp3,encode,theora,jpeg2k?]
			>=media-video/libav-9[x264,mp3,encode,theora,jpeg2k?]
		)
	)
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( media-libs/openjpeg )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openimageio? ( >=media-libs/openimageio-1.1.5 )
	openexr? ( media-libs/openexr )
	sdl? ( media-libs/libsdl[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )"
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
	if ! use sm_20 && ! use sm_21 && ! use sm_30 ! use sm_35; then
		if use cuda; then
			ewarn "You have not chosen a CUDA kernel. It takes an extreamly long time"
			ewarn "to compile all the CUDA kernels. Check http://www.nvidia.com/object/cuda_gpus.htm"
			ewarn "for your gpu and enable the matching sm_?? use flag to save time."
		fi
	else
		if ! use cuda; then
			ewarn "You have enabled a CUDA kernel (sm_??),  but you have not set"
			ewarn "'cuda' USE. CUDA will not be compiled until you do so."
		fi
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/01-${PN}-2.68-doxyfile.patch \
		"${FILESDIR}"/02-${PN}-2.71-unbundle-colamd.patch \
		"${FILESDIR}"/04-${PN}-2.71-unbundle-glog.patch \
		"${FILESDIR}"/05-${PN}-2.72-unbundle-eigen3.patch \
		"${FILESDIR}"/06-${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/07-${PN}-2.70-sse2.patch \
		"${FILESDIR}"/08-${PN}-2.71-gflags.patch \
		"${FILESDIR}"/09-${PN}-2.72-unbundle-minilzo.patch

	epatch_user

	# remove some bundled deps
	rm -r \
		extern/Eigen3 \
		extern/libopenjpeg \
		extern/glew \
		extern/colamd \
		extern/lzo \
		extern/libmv/third_party/{glog,gflags} \
		extern/binreloc \
		|| die

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
			cd "${S}"/release/datafiles/locale/po
			for i in *.po ; do
				mylang=${i%.po}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
#	append-cxxflags -std=gnu++11
	append-lfs-flags

	local mycmakeargs=""
	#CUDA Kernal Selection
	local CUDA_ARCH=""
	if use cuda; then
		if use sm_20; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH+=";sm_20"
			else
				CUDA_ARCH="sm_20"
			fi
		fi
		if use sm_21; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH+=";sm_21"
			else
				CUDA_ARCH="sm_21"
			fi
		fi
		if use sm_30; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH+=";sm_30"
			else
				CUDA_ARCH="sm_30"
			fi
		fi
		if use sm_35; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH+=";sm_35"
			else
				CUDA_ARCH="sm_35"
			fi
		fi

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_ARCH=${CUDA_ARCH}
			)
		fi
		mycmakeargs+=(
			-DWITH_CYCLES_CUDA=ON
			-DWITH_CYCLES_CUDA_BINARIES=ON
			-DCUDA_INCLUDES=/opt/cuda/include
			-DCUDA_LIBRARIES=/opt/cuda/lib64
			-DCUDA_NVCC=/opt/cuda/bin/nvcc
		)
	fi

	mycmakeargs+=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DWITH_INSTALL_PORTABLE=OFF
		$(cmake-utils_use_with boost BOOST)
		$(cmake-utils_use_with tomato LIBMV)
		$(cmake-utils_use_with compositor COMPOSITOR)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with collada OPENCOLLADA)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with oceansim MOD_OCEANSIM)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with jack JACK_DYNLOAD)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with openimageio OPENIMAGEIO)
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with opennl OPENNL)
		$(cmake-utils_use_with osl CYCLES_OSL)
		$(cmake-utils_use_with osl LLVM)
		$(cmake-utils_use_with freestyle FREESTYLE)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sse2 SSE2)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with colorio OPENCOLORIO)
		$(cmake-utils_use_with cin IMAGE_CINEON)
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		$(cmake-utils_use_with debug DEBUG)
		$(cmake-utils_use_with doc DOCS)
		$(cmake-utils_use_with eltopo ELTOPO)
		$(cmake-utils_use_with buildinfo BUILDINFO)
		$(cmake-utils_use_with !X HEADLESS)
		$(cmake-utils_use_with lzma LZMA)
		$(cmake-utils_use_with valgrind VALGRIND)
		$(cmake-utils_use_with quicktime QUICKTIME)
		$(cmake-utils_use_with openvdb CYCLES_OPENVDB)
		-DWITH_BUILTIN_GLEW=OFF
		-DWITH_MOD_CLOTH_ELTOPO=OFF
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
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
