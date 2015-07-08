 
# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/blender-9999.ebuild,v 1.6 2014/11/30 23:00:00 brothermechanic Exp $

EAPI=5
PYTHON_COMPAT=( python3_4 )

BLENDGIT_URI="http://git.blender.org"
EGIT_REPO_URI="${BLENDGIT_URI}/blender.git"
BLENDER_ADDONS_URI="${BLENDGIT_URI}/blender-addons.git"
BLENDER_ADDONS_CONTRIB_URI="${BLENDGIT_URI}/blender-addons-contrib.git"
BLENDER_TRANSLATIONS_URI="${BLENDGIT_URI}/blender-translations.git"

inherit cmake-utils eutils python-single-r1 gnome2-utils fdo-mime pax-utils git-2 versionator toolchain-funcs flag-o-matic

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"

LICENSE="|| ( GPL-2 BL )"
SLOT="0"
KEYWORDS=""
IUSE_BUILD="+blender game-engine -player +bullet collada +nls -ndof +cycles freestyle +opencolorio"
IUSE_COMPILER="buildinfo +openmp +sse +sse2"
IUSE_SYSTEM="X -portable -valgrind -debug -doc"
IUSE_IMAGE="+openimageio -dpx -dds +openexr -jpeg2k -redcode tiff"
IUSE_CODEC="+openal sdl jack avi +ffmpeg -sndfile +quicktime"
IUSE_COMPRESSION="-lzma +lzo"
IUSE_MODIFIERS="+fluid +smoke +boolean +remesh oceansim +decimate"
IUSE_MODULES="osl +openvdb +addons contrib -alembic opensubdiv"
IUSE_GPU="+opengl +cuda -sm_30 -sm_35 -sm_50"
IUSE="${IUSE_BUILD} ${IUSE_COMPILER} ${IUSE_SYSTEM} ${IUSE_IMAGE} ${IUSE_CODEC} ${IUSE_COMPRESSION} ${IUSE_MODIFIERS} ${IUSE_MODULES} ${IUSE_GPU}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	            redcode? ( ffmpeg jpeg2k )
			player? ( game-engine opengl )
			  game-engine? ( bullet opengl )
			    openvdb ( !osl )"

LANGS="en ar bg ca cs de el es es_ES fa fi fr he hr hu id it ja ky ne nl pl pt pt_BR ru sr sr@latin sv tr uk zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
	REQUIRED_USE+=" linguas_${X}? ( nls )"
done

RDEPEND="${PYTHON_DEPS}
	dev-vcs/git
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-libs/jemalloc
	sys-libs/zlib
	sci-libs/fftw:3.0
	media-libs/freetype
	media-libs/libpng
	sci-libs/ldl
	virtual/libintl
	virtual/jpeg
	dev-libs/boost[threads(+)]
	sci-libs/colamd
	opengl? ( 
		virtual/opengl
		media-libs/glew
		virtual/glu
	)
	X? (
	   x11-libs/libXi
	   x11-libs/libX11
	   x11-libs/libXxf86vm
	)
	opencolorio? ( media-libs/opencolorio )
	cycles? (
		openimageio? ( >=media-libs/openimageio-1.1.5 )
		cuda? ( dev-util/nvidia-cuda-toolkit )
		osl? (
		      >=sys-devel/llvm-3.1
		      media-gfx/osl
		      )
		openvdb? ( media-gfx/openvdb[openvdb-compression] )
	)
	sdl? ( media-libs/libsdl[sound,joystick] )
	tiff? ( media-libs/tiff )
	openexr? ( media-libs/openexr )
	ffmpeg? (
		>=media-video/ffmpeg-2.2[x264,xvid,mp3,encode]
		jpeg2k? ( >=media-video/ffmpeg-2.2[x264,xvid,mp3,encode,jpeg2k] )
	)
	openal? ( >=media-libs/openal-1.6.372 )
	jack? ( media-sound/jack-audio-connection-kit )
	sndfile? ( media-libs/libsndfile )
	collada? ( media-libs/opencollada )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	quicktime? ( media-libs/libquicktime )
	app-arch/lzma
	valgrind? ( dev-util/valgrind )
	lzma? ( app-arch/lzma )
	lzo? ( dev-libs/lzo )
	alembic? ( media-libs/alembic )
	opensubdiv? ( media-libs/opensubdiv )"

DEPEND="${RDEPEND}
	dev-cpp/eigen:3
	nls? ( sys-devel/gettext )
	doc? (
		dev-python/sphinx
		app-doc/doxygen[-nodot(-),dot(+)]
	)"

src_unpack(){
if [ "${PV}" = "9999" ];then
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
else
	unpack ${A}
fi
}

pkg_setup() {
	python-single-r1_pkg_setup
	enable_openmp="OFF"
	if use openmp; then
		if tc-has-openmp; then
			enable_openmp="ON"
		else
			ewarn "You are using gcc built without 'openmp' USE."
			ewarn "Switch CXX to an OpenMP capable compiler."
			die "Need openmp"
		fi
	fi

	if ! use sm_30 && ! use sm_35 && ! use sm_50; then
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
#	rm -r "${WORKDIR}/${P}"/release/scripts/addons_contrib/sequencer_extra_actions/* \
#	|| die

	epatch "${FILESDIR}"/01-${PN}-2.68-doxyfile.patch \
		"${FILESDIR}"/06-${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/07-${PN}-2.70-sse2.patch \
		"${FILESDIR}"/sequencer_extra_actions-3.8.patch.bz2
	
	epatch_user

	# remove some bundled deps
	rm -r \
		extern/libopenjpeg \
		extern/glew \
		extern/glew-es \
		|| die

	# we don't want static glew, but it's scattered across
	# thousand files
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	sed -i \
		-e '/-DGLEW_STATIC/d' \
		$(find . -type f -name "CMakeLists.txt") || die

	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"
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
	append-flags -funsigned-char -fno-strict-aliasing -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -DWITH_OPENNL -DHAVE_STDBOOL_H
	#append-lfs-flags
	local mycmakeargs=""
	#CUDA Kernal Selection
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
		if use sm_50; then
			if [[ -n "${CUDA_ARCH}" ]] ; then
				CUDA_ARCH="${CUDA_ARCH};sm_50"
			else
				CUDA_ARCH="sm_50"
			fi
		fi

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs="${mycmakeargs} -DCYCLES_CUDA_BINARIES_ARCH=${CUDA_ARCH}"
		fi
		mycmakeargs="${mycmakeargs}
		-DWITH_CYCLES_CUDA=ON
		-DWITH_CYCLES_CUDA_BINARIES=ON
		-D
		-DCUDA_INCLUDES=/opt/cuda/include
		-DCUDA_LIBRARIES=/opt/cuda/lib64
		-DCUDA_NVCC=/opt/cuda/bin/nvcc"
	fi

	#make DESTDIR="${D}" install didn't work
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		$(cmake-utils_use_with blender BLENDER)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with collada OPENCOLLADA)
		-DWITH_FFTW3=ON
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with cycles CYCLES)
		-DWITH_BOOST=ON
		-DWITH_BULLET=ON
		-DWITH_HDF5=ON
		-DWITH_SYSTEM_EIGEN3=ON
		$(cmake-utils_use_with freestyle FREESTYLE)
		$(cmake-utils_use_with opencolorio OPENCOLORIO)
		
		$(cmake-utils_use_with buildinfo BUILDINFO)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sse2 SSE2)
		
		$(cmake-utils_use_with X X11)
		$(cmake-utils_use_with !X HEADLESS)
		$(cmake-utils_use_with X X11_XF86VMODE)
		$(cmake-utils_use_with X X11_XINPUT)
		$(cmake-utils_use_with X GHOST_XDND)
		$(cmake-utils_use_with valgrind VALGRIND)
		$(cmake-utils_use_with debug DEBUG)
		$(cmake-utils_use_with debug GPU_DEBUG)
		$(cmake-utils_use_with debug WITH_CYCLES_DEBUG)
		$(cmake-utils_use_with doc DOCS)
		$(cmake-utils_use_with doc DOC_MANPAGE)
		
		$(cmake-utils_use_with openimageio OPENIMAGEIO)
		$(cmake-utils_use_with dpx IMAGE_CINEON)
		$(cmake-utils_use_with dds IMAGE_DDS)
		-DWITH_IMAGE_HDR=ON
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sdl SDL_DYNLOAD)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with jack JACK_DYNLOAD)
		$(cmake-utils_use_with avi CODEC_AVI)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with quicktime QUICKTIME)
		
		$(cmake-utils_use_with lzma LZMA)
		$(cmake-utils_use_with lzo LZO)
		
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with oceansim MOD_OCEANSIM)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		
		$(cmake-utils_use_with osl LLVM)
		-DLLVM_STATIC=OFF
		-DLLVM_LIBRARY="/usr/lib"
		$(cmake-utils_use_with osl CYCLES_OSL)
		$(cmake-utils_use_with openvdb OPENVDB)
		$(cmake-utils_use_with openvdb OPENVDB_BLOSC)
		$(cmake-utils_use_with alembic ALEMBIC)
		$(cmake-utils_use_with alembic STATICALEMBIC)
		$(cmake-utils_use_with opensubdiv OPENSUBDIV)
		
		$(cmake-utils_use_with portable INSTALL_PORTABLE)
		$(cmake-utils_use_with portable STATIC_LIBS)
		$(cmake-utils_use_with portable PYTHON_INSTALL)
		$(cmake-utils_use_with portable PYTHON_INSTALL_NUMPY)
		$(cmake-utils_use_with portable PYTHON_INSTALL_REQUESTS)
		
		$(cmake-utils_use_with opengl SYSTEM_GLEW)
		$(cmake-utils_use_with opengl SYSTEM_GLES)
		$(cmake-utils_use_with opengl GL_PROFILE_COMPAT)
		$(cmake-utils_use_with lzo SYSTEM_LZO)
		$(cmake-utils_use_with jpeg2k SYSTEM_OPENJPEG)
		
		-DWITH_OPENNL=ON"

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

	python_fix_shebang "${ED%/}"/usr/bin/blender-thumbnailer.py
	python_optimize "${ED%/}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender compiles from master think by default"
	elog "You may change a branch and a rev, for ex, in /etc/portage/env/blender"
	elog "EGIT_COMMIT="v2.74""
	elog "EGIT_BRANCH="master""
	elog "and don't forget add to /etc/portage/package.env"
	elog "media-gfx/blender blender"
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
