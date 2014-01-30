# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/blender/blender-9999.ebuild,v 1.4 2013/11/08 19:24:12 brothermechanic Exp $

EAPI=5

if [ "${PV}" = "9999" ];then
BLENDGIT_URI="http://git.blender.org"
EGIT_REPO_URI="${BLENDGIT_URI}/blender.git"
BLENDER_ADDONS_URI="${BLENDGIT_URI}/blender-addons.git"
BLENDER_ADDONS_CONTRIB_URI="${BLENDGIT_URI}/blender-addons-contrib.git"
BLENDER_TRANSLATIONS_URI="${BLENDGIT_URI}/blender-translations.git"
SCM="git-2"
else
SRC_URI="http://download.blender.org/source/${P}.tar.gz"
fi

inherit cmake-utils subversion eutils ${SCM}
PYTHON_DEPEND="3:3.3"

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"

LICENSE="|| ( GPL-2 BL )"
SLOT="2.6"
KEYWORDS=""
IUSE_MODULES="+cycles +ocio -osl openvdb +freestyle +compositor +tomato +game-engine player +addons +contrib +X"
IUSE_MODIFIERS="+fluid +boolean +decimate +remesh +smoke +oceansim eltopo"
IUSE_CODECS="+ffmpeg openexr -jpeg2k -dds -tiff -cin -redcode quicktime"
IUSE_SYSTEM="+openmp +fftw sndfile jack +sdl -openal +nls ndof +collada -doc -debug -lzma -valgrind +buildinfo"
IUSE_GPU="-cuda -sm_20 -sm_21 -sm_30"
IUSE="${IUSE_MODULES} ${IUSE_MODIFIERS} ${IUSE_CODECS} ${IUSE_SYSTEM} ${IUSE_GPU}"

REQUIRED_USE="cycles? ( ocio )
		cuda? ( cycles )
		  osl? ( cycles )
		    redcode? ( ffmpeg jpeg2k )"

LANGS="en ar bg ca cs de el es es_ES fa fi fr he hr hu id it ja ky ne nl pl pt pt_BR ru sr sr@latin sv tr uk zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
	REQUIRED_USE+=" linguas_${X}? ( nls )"
done

DEPEND="dev-cpp/gflags
	dev-cpp/glog[gflags]
	dev-python/numpy[python_targets_python3_3]
	sci-libs/colamd
	sci-libs/ldl
	virtual/glu
	virtual/libintl
	dev-lang/python:3.3
	virtual/jpeg
	media-libs/libpng:0
	media-libs/tiff:0
	media-libs/libsamplerate
	X? ( x11-libs/libXi
		x11-libs/libX11
		virtual/opengl
		media-libs/freetype
		media-libs/glew
	)
	eltopo? ( virtual/lapack )
	sys-libs/zlib
	ocio? ( >=media-libs/opencolorio-1.0.8 )
	cycles? (
		>=media-libs/openimageio-1.1.5
		>=dev-libs/boost-1.49.0[threads(+)]
		cuda? ( dev-util/nvidia-cuda-toolkit )
		osl? ( =media-gfx/osl-9999 )
		osl? ( >=sys-devel/llvm-3.1 )
		openvdb? ( media-gfx/openvdb )
	)
	sdl? ( media-libs/libsdl[audio,joystick] )
	openexr? ( media-libs/openexr )
	ffmpeg? (
		>=media-video/ffmpeg-0.10[x264,xvid,mp3,encode]
		jpeg2k? ( >=media-video/ffmpeg-0.10[x264,xvid,mp3,encode,jpeg2k] )
	)
	openal? ( >=media-libs/openal-1.6.372 )
	fftw? (	sci-libs/fftw:3.0 )
	jack? (	media-sound/jack-audio-connection-kit )
	sndfile? ( media-libs/libsndfile )
	collada? ( media-libs/opencollada )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.2 )
	ndof? ( dev-libs/libspnav )
	quicktime? ( media-libs/libquicktime )
	lzma? ( app-arch/lzma )
	valgrind? ( dev-util/valgrind )"

RDEPEND="${DEPEND}
	dev-cpp/eigen:3
	nls? ( sys-devel/gettext )
	doc? ( dev-python/sphinx
	app-doc/doxygen[-nodot(-),dot(+)]
	)"

# configure internationalization only if LINGUAS have more
# languages than 'en', otherwise must be disabled
# A user may have en and en_US enabled. For libre/openoffice
# as an example.
for mylang in "${LINGUAS}" ; do
	if [[ ${mylang} != "en" && ${mylang} != "en_US" && ${mylang} != "" ]]; then
		DEPEND="${DEPEND}
			sys-devel/gettext"
		break;
	fi
done

# S="${WORKDIR}/${PN}"

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
	enable_openmp="OFF"
	if use openmp; then
		if tc-has-openmp; then
			enable_openmp="ON"
		else
			ewarn "You are using gcc built without 'openmp' USE."
			ewarn "Switch CXX to an OpenMP capable compiler."
			die	"Need openmp"
		fi
	fi

	if ! use sm_20 && ! use sm_21 && ! use sm_30; then
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
		"${FILESDIR}"/02-${PN}-2.68-unbundle-colamd.patch \
		"${FILESDIR}"/03-${PN}-2.68-remove-binreloc.patch \
		"${FILESDIR}"/04-${PN}-2.68-unbundle-glog.patch \
		"${FILESDIR}"/05-${PN}-2.68-unbundle-eigen3.patch \
		"${FILESDIR}"/06-${PN}-2.68-fix-install-rules.patch \
		"${FILESDIR}"/${PN}-desktop.patch

	rm -r \
		"${WORKDIR}/${P}"/extern/Eigen3 \
		"${WORKDIR}/${P}"/extern/libopenjpeg \
		"${WORKDIR}/${P}"/extern/glew \
		"${WORKDIR}/${P}"/extern/colamd \
		"${WORKDIR}/${P}"/extern/binreloc \
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
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"
}

src_configure() {

	local mycmakeargs=""

	#CUDA Kernal Selection
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
		-DCUDA_LIBRARIES=/opt/cuda/lib64
		-DCUDA_NVCC=/opt/cuda/bin/nvcc"
	fi

	#iconv is enabled when international is enabled
	if use nls; then
		for mylang in "${LINGUAS}" ; do
			if [[ ${mylang} != "en" && ${mylang} != "en_US" && ${mylang} != "" ]]; then
				mycmakeargs="${mycmakeargs} -DWITH_INTERNATIONAL=ON"
				break;
			fi
		done
	fi

		#modified the install prefix in order to get everything to work for src_install
	#make DESTDIR="${D}" install didn't work
	mycmakeargs="${mycmakeargs}
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_BUILTIN_GLEW=OFF
		-DWITH_MOD_CLOTH_ELTOPO=OFF
		-DPYTHON_VERSION="3.3"
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_INSTALL_PORTABLE=OFF
		-DCMAKE_INSTALL_PREFIX="${D}/usr"
		$(cmake-utils_use_with tomato LIBMV)
		$(cmake-utils_use_with compositor COMPOSITOR)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with ocio OPENCOLORIO)
		$(cmake-utils_use_with osl CYCLES_OSL)
		$(cmake-utils_use_with osl LLVM)
		$(cmake-utils_use_with freestyle FREESTYLE)
		$(cmake-utils_use_with player PLAYER)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with cin IMAGE_CINEON)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with openal OPENAL)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with boolean MOD_BOOLEAN)
		$(cmake-utils_use_with decimate MOD_DECIMATE)
		$(cmake-utils_use_with fluid MOD_FLUID)
		$(cmake-utils_use_with oceansim MOD_OCEANSIM)
		$(cmake-utils_use_with remesh MOD_REMESH)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with collada OPENCOLLADA)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with smoke MOD_SMOKE)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with debug DEBUG)
		$(cmake-utils_use_with doc DOCS)
		$(cmake-utils_use_with eltopo ELTOPO)
		$(cmake-utils_use_with buildinfo BUILDINFO)
		$(cmake-utils_use_with !X HEADLESS)
		$(cmake-utils_use_with lzma LZMA)
		$(cmake-utils_use_with valgrind VALGRIND)
		$(cmake-utils_use_with quicktime QUICKTIME)
		$(cmake-utils_use_with openvdb CYCLES_OPENVDB)"

	# FIX: Game Engine module needs to be active to build the Blender Player
	if ! use game-engine && use player; then
		elog "Forcing Game Engine [+game-engine] as required by Blender Player [+player]"
		mycmakeargs="${mycmakeargs} -DWITH_GAMEENGINE=ON"
	else
		mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with game-engine GAMEENGINE)"
	fi

	if use redcode && ! use jpeg2k && ! use ffmpeg; then
		elog "Forcing OpenJPEG as required by Redcode [+redcode]"
		mycmakeargs="${mycmakeargs} -DWITH_IMAGE_OPENJPEG=ON"
	else
		mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)"
	fi

	cmake-utils_src_configure
}

src_install() {
	cd "${CMAKE_BUILD_DIR}"
	emake install || die
}

pkg_preinst() {
	cd "${D}/usr"
	VERSION=`ls share/blender/`

	mv "bin/blender" "bin/blender-bin-${SLOT}"
	mv "bin/blender-thumbnailer.py" "bin/blender-thumbnailer-${SLOT}.py"
	if use player; then
		mv "bin/blenderplayer" "bin/blenderplayer-${SLOT}"
	fi

	# create a wrapper
	cat <<- EOF >> "bin/blender-${SLOT}"
		#!/bin/sh

		# stop this script if the local blender path is a symlink
		 if [ -L \${HOME}/.blender ]; then
			echo "Detected a symbolic link for \${HOME}/.blender"
			echo "Sorry, to avoid dangerous situations, the Blender binary can"
			echo "not be started until	you have removed the symbolic link:"
			echo "  # rm -i \${HOME}/.blender"
			exit 1
		fi

		export BLENDER_SYSTEM_SCRIPTS="/usr/share/blender/${VERSION}/scripts"
		export BLENDER_SYSTEM_DATAFILES="/usr/share/blender/${VERSION}/datafiles"
		exec /usr/bin/blender-bin-${SLOT} \$*
	EOF

	chmod 755 "bin/blender-${SLOT}"
}
