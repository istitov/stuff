# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/blender-9999.ebuild,v 1.5 2014/11/12 12:00:00 brothermechanic Exp $

# TODO:
#   bundled-deps: bullet is modified
#   multiple python abi?

EAPI=5
PYTHON_COMPAT=( python3_4 )
#PATCHSET="1"

inherit multilib fdo-mime gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs git-2

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

BLENDGIT_URI="http://git.blender.org"
EGIT_REPO_URI="${BLENDGIT_URI}/blender.git"
#EGIT_BRANCH="fracture_modifier"
BLENDER_ADDONS_URI="${BLENDGIT_URI}/blender-addons.git"
BLENDER_ADDONS_CONTRIB_URI="${BLENDGIT_URI}/blender-addons-contrib.git"
BLENDER_TRANSLATIONS_URI="${BLENDGIT_URI}/blender-translations.git"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"
IUSE_MODULES="+cycles +openimageio +opencolorio -osl openvdb +freestyle +compositor +tomato +game-engine player +addons +contrib +X"
IUSE_MODIFIERS="+fluid +boolean +decimate +remesh +smoke +oceansim"
IUSE_CODECS="+ffmpeg openexr -jpeg2k -dds -tiff -cin -redcode quicktime"
IUSE_SYSTEM="+openmp +sse +sse2 +fftw sndfile jack +sdl -openal +nls ndof +collada -doc -debug -lzma -valgrind +buildinfo"
IUSE_GPU="-sm_30 -sm_35 -cuda"
IUSE="${IUSE_MODULES} ${IUSE_MODIFIERS} ${IUSE_CODECS} ${IUSE_SYSTEM} ${IUSE_GPU}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine )
	redcode? ( jpeg2k ffmpeg )
	oceansim? ( fftw )
	osl? ( cycles )
	cuda? ( cycles )
	openvdb? ( cycles )
	cycles? ( openimageio opencolorio openexr tiff ) "

RDEPEND="
	${PYTHON_DEPS}
	>=dev-cpp/gflags-2.1.1-r1
	>=dev-cpp/glog-0.3.3-r1[gflags]
	>=dev-libs/lzo-2.08:2
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	sci-libs/colamd
	sci-libs/ldl
	sys-libs/zlib
	lzma? ( app-arch/lzma )
	valgrind? ( dev-util/valgrind )
	virtual/glu
	virtual/libintl
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	X? ( x11-libs/libXi
		x11-libs/libX11
		virtual/opengl
		>=media-libs/freetype-2.0
		media-libs/glew
	)
	cycles? (
		openimageio? ( >=media-libs/openimageio-1.1.5 )
		opencolorio? ( >=media-libs/opencolorio-1.0.8 )
		>=dev-libs/boost-1.44[nls?,threads(+)]
		cuda? ( dev-util/nvidia-cuda-toolkit )
		osl? (
		      >=sys-devel/llvm-3.1
		      media-gfx/osl
		      )
		openvdb? ( media-gfx/openvdb )
	)
	ffmpeg? (
		>=media-video/ffmpeg-2.2[x264,xvid,mp3,encode]
		jpeg2k? ( >=media-video/ffmpeg-2.2[x264,xvid,mp3,encode,jpeg2k] )
	)
	fftw? ( sci-libs/fftw:3.0 )
	collada? ( media-libs/opencollada )
	media-libs/libsamplerate
	quicktime? ( media-libs/libquicktime )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( media-libs/openjpeg:0 )
	media-libs/libpng
	virtual/jpeg
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openexr? ( media-libs/openexr )
	sdl? ( media-libs/libsdl[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	virtual/lapack
	"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.1.3:3
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx
	)
	nls? ( sys-devel/gettext )"


src_unpack(){
	git-2_src_unpack
	unset EGIT_BRANCH EGIT_COMMIT
	if use addons; then
		unset EGIT_BRANCH EGIT_COMMIT
		EGIT_SOURCEDIR="${WORKDIR}/${P}/release/scripts/addons" \
		EGIT_REPO_URI="${BLENDER_ADDONS_URI}" \
		git-2_src_unpack
	fi
		if use contrib; then
			unset EGIT_BRANCH EGIT_COMMIT
			EGIT_SOURCEDIR="${WORKDIR}/${P}/release/scripts/addons_contrib" \
			EGIT_REPO_URI="${BLENDER_ADDONS_CONTRIB_URI}" \
			git-2_src_unpack
		fi
		if use nls; then
			unset EGIT_BRANCH EGIT_COMMIT
			EGIT_SOURCEDIR="${WORKDIR}/${P}/release/datafiles/locale" \
			EGIT_REPO_URI="${BLENDER_TRANSLATIONS_URI}" \
			git-2_src_unpack
		fi

}	
	
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
		"${FILESDIR}"/02-${PN}-2.71-unbundle-colamd.patch \
		"${FILESDIR}"/06-${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/07-${PN}-2.70-sse2.patch \
		"${FILESDIR}"/09-${PN}-2.72b-unbundle-minilzo.patch \
		"${FILESDIR}"/sequencer_extra_actions-3.8.patch.bz2

	epatch_user

	# remove some bundled deps
	rm -r \
		extern/libopenjpeg \
		extern/glew \
		extern/colamd \
		extern/lzo \
		|| die

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
	append-lfs-flags
	
	local mycmakeargs=""
	#CUDA Kernel Selection
	local CUDA_ARCH=""
	if use cuda; then
		if use sm_30; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_30"
			else
				CUDA_ARCH="sm_30"
			fi
		fi
		if use sm_35; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_35"
			else
				CUDA_ARCH="sm_35"
			fi
		fi

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs="${mycmakeargs} -DCYCLES_CUDA_ARCH=${CUDA_ARCH}"
		fi
		mycmakeargs=( ${mycmakeargs}
		-DWITH_CYCLES_CUDA=ON
		-DWITH_CYCLES_CUDA_BINARIES=ON
		-DCUDA_INCLUDES=/opt/cuda/include
		-DCUDA_LIBRARIES=/opt/cuda/lib64
		-DCUDA_NVCC=/opt/cuda/bin/nvcc )
	fi


	mycmakeargs=( ${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX=/usr
		-DWITH_BOOST=ON
		-DWITH_BULLET=ON
		-DDWITH_OPENNL=ON
		$(cmake-utils_use_with tomato LIBMV)
		$(cmake-utils_use_with compositor COMPOSITOR)
		$(cmake-utils_use_with osl CYCLES_OSL)
		$(cmake-utils_use_with osl LLVM)
		$(cmake-utils_use_with freestyle FREESTYLE)
		$(cmake-utils_use_with cin IMAGE_CINEON)
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with oceansim MOD_OCEANSIM)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		$(cmake-utils_use_with buildinfo BUILDINFO)
		$(cmake-utils_use_with !X HEADLESS)
		$(cmake-utils_use_with lzma LZMA)
		$(cmake-utils_use_with valgrind VALGRIND)
		$(cmake-utils_use_with quicktime QUICKTIME)
		$(cmake-utils_use_with openvdb CYCLES_OPENVDB)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with collada OPENCOLLADA)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with jack JACK_DYNLOAD)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with openimageio OPENIMAGEIO)
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sse2 SSE2)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with opencolorio OPENCOLORIO)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with debug DEBUG)
		-DWITH_INSTALL_PORTABLE=OFF
		-DWITH_BUILTIN_GLEW=OFF
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
