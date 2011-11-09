# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-2"
	EXPERIMENTAL="true"
fi

inherit base autotools multilib flag-o-matic toolchain-funcs ${GIT_ECLASS}

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"

FOLDER="${PV/_rc*/}"
[[ ${PV/_rc*/} == ${PV} ]] || FOLDER+="/RC"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

#SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${FOLDER}/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}"
fi

# Most of the code is MIT/X11.
# ralloc is LGPL-3
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT LGPL-3 SGI-B-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"

INTEL_CARDS="i915 i965 intel"
RADEON_CARDS="r100 r200 r300 r600 radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} nouveau vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	bindist +classic d3d debug +egl g3dvl +gallium gbm gles1 gles2 +llvm +nptl openvg osmesa pax_kernel pic selinux shared-dricore +shared-glapi vdpau wayland xvmc kernel_FreeBSD xorg"

REQUIRED_USE="
	d3d?    ( gallium )
	g3dvl?  ( gallium )
	llvm?   ( gallium )
	openvg? ( gallium )
	egl? ( shared-glapi )
	gallium? (
		video_cards_r300?   ( x86? ( llvm ) amd64? ( llvm ) )
		video_cards_radeon? ( x86? ( llvm ) amd64? ( llvm ) )
	)
	g3dvl? ( || ( vdpau xvmc ) )
	vdpau? ( g3dvl )
	xvmc?  ( g3dvl )
	video_cards_i915?   ( classic )
	video_cards_r100?   ( classic )
	video_cards_r200?   ( classic )
	video_cards_vmware? ( gallium )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.24"
# not a runtime dependency of this package, but dependency of packages which
# depend on this package, bug #342393
EXTERNAL_DEPEND="
	>=x11-proto/dri2proto-2.6
	>=x11-proto/glproto-1.4.14
"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="${EXTERNAL_DEPEND}
	!<x11-base/xorg-server-1.7
	!<=x11-proto/xf86driproto-2.0.3
	classic? ( app-admin/eselect-mesa )
	gallium? ( app-admin/eselect-mesa )
	>=app-admin/eselect-opengl-1.2.2
	dev-libs/expat
	gbm? ( sys-fs/udev )
	>=x11-libs/libX11-1.3.99.901
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXxf86vm
	d3d? ( app-emulation/wine )
	vdpau? ( >=x11-libs/libvdpau-0.4.1 )
	wayland? ( x11-base/wayland )
	xvmc? ( x11-libs/libXvMC )
	${LIBDRM_DEPSTRING}[video_cards_nouveau?,video_cards_vmware?]
"
for card in ${INTEL_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )
	"
done

for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )
	"
done

DEPEND="${RDEPEND}
	llvm? ( >=sys-devel/llvm-2.9 )
	=dev-lang/python-2*
	dev-libs/libxml2[python]
	dev-util/pkgconfig
	sys-devel/bison
	sys-devel/flex
	x11-misc/makedepend
	>=x11-proto/xextproto-7.0.99.1
	x11-proto/xf86driproto
	x11-proto/xf86vidmodeproto
"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, fbcon, no-X configs

pkg_setup() {
	# gcc 4.2 has buggy ivopts
	if [[ $(gcc-version) = "4.2" ]]; then
		append-flags -fno-ivopts
	fi

	# recommended by upstream
	append-flags -ffast-math
}

src_unpack() {
	default
	[[ $PV = 9999* ]] && git-2_src_unpack
}

src_prepare() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi

	# fix for hardened pax_kernel, bug 240956
	[[ ${PV} != 9999* ]] && epatch "${FILESDIR}"/glx_ro_text_segm.patch

	# Solaris needs some recent POSIX stuff in our case
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i -e "s/-DSVR4/-D_POSIX_C_SOURCE=200112L/" configure.ac || die
	fi

	base_src_prepare

	eautoreconf
}

src_configure() {
	local myconf

	if use classic; then
	# Configurable DRI drivers
		driver_enable swrast

	# Intel code
		driver_enable video_cards_i915 i915
		driver_enable video_cards_i965 i965
			if ! use video_cards_i915 && \
				! use video_cards_i965; then
			driver_enable video_cards_intel i915 i965
		fi

		# Nouveau code
		driver_enable video_cards_nouveau nouveau

		# ATI code
		driver_enable video_cards_r100 radeon
		driver_enable video_cards_r200 r200
		driver_enable video_cards_r300 r300
		driver_enable video_cards_r600 r600
		if ! use video_cards_r100 && \
				! use video_cards_r200 && \
				! use video_cards_r300 && \
				! use video_cards_r600; then
			driver_enable video_cards_radeon radeon r200 r300 r600
		fi
	fi

	if use egl; then
		myconf+="
			--with-egl-platforms=x11$(use wayland && echo ",wayland")$(use gbm && echo ",drm")
			$(use_enable gallium gallium-egl)
		"
	fi

	if use !gallium && use !classic; then
		ewarn "You enabled neither classic nor gallium USE flags. No hardware"
		ewarn "drivers will be built."
	fi
	if use gallium; then
		myconf+="
			$(use_enable d3d d3d1x)
			$(use_enable g3dvl gallium-g3dvl)
			$(use_enable llvm gallium-llvm)
			$(use_enable openvg)
			$(use_enable vdpau)
			$(use_enable xvmc)
		"
		gallium_enable swrast
		gallium_enable video_cards_vmware svga
		gallium_enable video_cards_nouveau nouveau
		gallium_enable video_cards_i915 i915
		gallium_enable video_cards_i965 i965
		if ! use video_cards_i915 && \
				! use video_cards_i965; then
			gallium_enable video_cards_intel i915 i965
		fi

		gallium_enable video_cards_r300 r300
		gallium_enable video_cards_r600 r600
		if ! use video_cards_r300 && \
				! use video_cards_r600; then
			gallium_enable video_cards_radeon r300 r600
		fi
	fi

	# x86 hardened pax_kernel needs glx-rts, bug 240956
	if use pax_kernel; then
		myconf+="
			$(use_enable x86 glx-rts)
		"
	fi

	econf \
		--disable-option-checking \
		--enable-dri \
		--enable-glx \
		--enable-xcb \
		$(use_enable !bindist texture-float) \
		$(use_enable debug) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable nptl glx-tls) \
		$(use_enable osmesa) \
		$(use_enable !pic asm) \
		$(use_enable shared-dricore) \
		$(use_enable shared-glapi) \
		$(use_enable xorg) \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		${myconf}
}

src_install() {
	base_src_install

	if use !bindist; then
		dodoc docs/patents.txt
	fi

	# Save the glsl-compiler for later use
	if ! tc-is-cross-compiler; then
		dobin "${S}"/src/glsl/glsl_compiler
	fi

	# Install config file for eselect mesa
	insinto /usr/share/mesa
	newins "${FILESDIR}/eselect-mesa.conf.7.12" eselect-mesa.conf

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${ED}"/usr/$(get_libdir)/lib{EGL,GL,OpenVG}.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${ED}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?

	if use classic || use gallium; then
			ebegin "Moving DRI/Gallium drivers for dynamic switching"
			local gallium_drivers=( i915_dri.so i965_dri.so r300_dri.so r600_dri.so swrast_dri.so )
			keepdir /usr/$(get_libdir)/dri
			dodir /usr/$(get_libdir)/mesa
			for x in ${gallium_drivers[@]}; do
				if [ -f "${S}/$(get_libdir)/gallium/${x}" ]; then
					mv -f "${ED}/usr/$(get_libdir)/dri/${x}" "${ED}/usr/$(get_libdir)/dri/${x/_dri.so/g_dri.so}" \
						|| die "Failed to move ${x}"
					insinto "/usr/$(get_libdir)/dri/"
					if [ -f "${S}/$(get_libdir)/${x}" ]; then
						insopts -m0755
						doins "${S}/$(get_libdir)/${x}"
					fi
				fi
			done
			for x in "${ED}"/usr/$(get_libdir)/dri/*.so; do
				if [ -f ${x} -o -L ${x} ]; then
					mv -f "${x}" "${x/dri/mesa}" \
						|| die "Failed to move ${x}"
				fi
			done
			pushd "${ED}"/usr/$(get_libdir)/dri || die "pushd failed"
			ln -s ../mesa/*.so . || die "Creating symlink failed"
			# remove symlinks to drivers known to eselect
			for x in ${gallium_drivers[@]}; do
				if [ -f ${x} -o -L ${x} ]; then
					rm "${x}" || die "Failed to remove ${x}"
				fi
			done
			popd
		eend $?
	fi
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
	# Select classic/gallium drivers
	if use classic || use gallium; then
		eselect mesa set --auto
	fi

	# warn about patent encumbered texture-float
	if use !bindist; then
		elog "USE=\"bindist\" was not set. Potentially patent encumbered code was"
		elog "enabled. Please see patents.txt for an explanation."
	fi

	local using_radeon r_flag
	for r_flag in ${RADEON_CARDS}; do
		if use video_cards_${r_flag}; then
			using_radeon=1
			break
		fi
	done

	if [[ ${using_radeon} = 1 ]] && ! has_version media-libs/libtxc_dxtn; then
		elog "Note that in order to have full S3TC support, it is necessary to install"
		elog "media-libs/libtxc_dxtn as well. This may be necessary to get nice"
		elog "textures in some apps, and some others even require this to run."
	fi
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
# TODO: avoid code duplication for a more elegant implementation
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

gallium_enable() {
	case $# in
		# for enabling unconditionally
		1)
			GALLIUM_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					GALLIUM_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
