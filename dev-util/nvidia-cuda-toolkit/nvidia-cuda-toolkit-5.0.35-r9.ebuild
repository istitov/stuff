# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/nvidia-cuda-toolkit/nvidia-cuda-toolkit-5.0.35-r3.ebuild,v 1.1 2013/02/13 22:02:07 jlec Exp $

EAPI=5

inherit cuda unpacker versionator

MYD=$(get_version_component_range 1)_$(get_version_component_range 2)
DISTRO=ubuntu11.10

DESCRIPTION="NVIDIA CUDA Toolkit (compiler and friends)"
HOMEPAGE="http://developer.nvidia.com/cuda"
CURI="http://developer.download.nvidia.com/compute/cuda/${MYD}/rel-update-1/installers/"
SRC_URI="
	amd64? ( ${CURI}/cuda_${PV}_linux_64_${DISTRO}.run )
	x86? ( ${CURI}/cuda_${PV}_linux_32_${DISTRO}.run )"

SLOT="0/${PV}"
LICENSE="NVIDIA-r1"
KEYWORDS="-* ~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="debugger doc eclipse profiler -cxx"

DEPEND=""
RDEPEND="${DEPEND}
	sys-devel/gcc[cxx?]
	x11-drivers/nvidia-drivers
	debugger? (
		sys-libs/libtermcap-compat
		sys-libs/ncurses[tinfo]
		)
	eclipse? ( >=virtual/jre-1.6 )
	profiler? ( >=virtual/jre-1.6 )"

S="${WORKDIR}"

QA_PREBUILT="opt/cuda/*"

pkg_setup() {
	# We don't like to run cuda_pkg_setup as it depends on us
	:
}

src_unpack() {
	unpacker
	unpacker run_files/cudatoolkit*run
	epatch ${FILESDIR}/${PN}-5.0-gcc48.patch
# https://projects.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/cuda&id=3f7b5c0fbba62743849d9b5902e0bee71ee7f422
# https://projects.archlinux.org/svntogit/community.git/commit/trunk/PKGBUILD?h=packages/cuda&id=3f7b5c0fbba62743849d9b5902e0bee71ee7f422

# Now, let the hacks begin!
# allow gcc 4.7 to work
	sed -i "/unsupported GNU/d" ${WORKDIR}/include/host_config.h
# allow gcc 4.8 to work
	sed -i "1 i #define __STRICT_ANSI__" ${WORKDIR}/include/cuda_runtime.h
	echo "#undef _GLIBCXX_ATOMIC_BUILTINS" >> ${WORKDIR}/include/cuda_runtime.h
	echo "#define _GLIBCXX_GTHREAD_USE_WEAK 0" >> ${WORKDIR}/include/cuda_runtime.h
# fix nvidia path fuckup
#	sed -i "s|/build/pkg||g" ${WORKDIR}/bin/nvvp
#	sed -i "s|/build/pkg||g" ${WORKDIR}/bin/nsight
}

src_prepare() {
	local cuda_supported_gcc

	cuda_supported_gcc="4.8"

	sed \
		-e "s:CUDA_SUPPORTED_GCC:${cuda_supported_gcc}:g" \
		"${FILESDIR}"/cuda-config.in > "${T}"/cuda-config || die

}

src_install() {
	local i j
	local remove="doc jre run_files install-linux.pl "
	local cudadir=/opt/cuda
	local ecudadir="${EPREFIX}"${cudadir}

	dodoc doc/*txt
	if use doc; then
		dodoc doc/pdf/*
		dohtml -r doc/html/*
	fi

	use debugger || remove+=" bin/cuda-gdb extras/Debugger"
	( use profiler || use eclipse ) || remove+=" libnsight"
	use amd64 || remove+=" cuda-installer.pl"

	if use profiler; then
		# hack found in install-linux.pl
		for j in nvvp nsight; do
			cat > bin/${j} <<- EOF
				#!${EPREFIX}/bin/sh
				LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${ecudadir}/lib:${ecudadir}/lib64 \
					UBUNTU_MENUPROXY=0 LIBOVERLAY_SCROLLBAR=0 \
					${ecudadir}/lib${j}/${j} -vm ${EPREFIX}/usr/bin/java
			EOF
			chmod a+x bin/${j}
		done
	else
		use eclipse || remove+=" libnvvp"
		remove+=" extras/CUPTI"
	fi

	for i in ${remove}; do
	ebegin "Cleaning ${i}..."
		if [[ -e ${i} ]]; then
			find ${i} -delete || die
			eend
		else
			eend $1
		fi
	done

	dodir ${cudadir}
	mv * "${ED}"${cudadir}

	cat > "${T}"/99cuda <<- EOF
		PATH=${ecudadir}/bin:${ecudadir}/libnvvp
		ROOTPATH=${ecudadir}/bin
		LDPATH=${ecudadir}/lib$(use amd64 && echo "64:${ecudadir}/lib")
	EOF
	doenvd "${T}"/99cuda

	make_wrapper nvprof "${EPREFIX}"${cudadir}/bin/nvprof "." ${ecudadir}/lib$(use amd64 && echo "64:${ecudadir}/lib")

	dobin "${T}"/cuda-config
}

pkg_postinst() {
	local a b
	a="$(version_sort $(cuda-config -s))"; a=( $a )
	# greatest supported version
	b=${a[${#a[@]}-1]}

	# if gcc and if not gcc-version is at least greatesst supported
	if [[ $(tc-getCC) == *gcc* ]] && \
		! version_is_at_least $(gcc-version) ${b}; then
			echo
			ewarn "gcc >= ${b} will not work with CUDA"
			ewarn "Make sure you set an earlier version of gcc with gcc-config"
			ewarn "or append --compiler-bindir= pointing to a gcc bindir like"
			ewarn "--compiler-bindir=${EPREFIX}/usr/*pc-linux-gnu/gcc-bin/gcc${b}"
			ewarn "to the nvcc compiler flags"
			echo
	fi
}
