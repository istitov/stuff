# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/v8/v8-3.9.24.7.ebuild,v 1.1 2012/04/10 10:53:02 phajdan.jr Exp $

EAPI="4"

PYTHON_DEPEND="2:2.6"

inherit eutils multilib pax-utils python toolchain-funcs versionator

DESCRIPTION="Google's open source JavaScript engine"
HOMEPAGE="http://code.google.com/p/v8"
SRC_URI="http://commondatastorage.googleapis.com/chromium-browser-official/${P}.tar.bz2"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~x64-macos ~x86-macos"
IUSE=""

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	# don't force 32-bits mode on Darwin
	sed -i -e '/-arch i386/d' build/gyp/pylib/gyp/generator/make.py || die
	# force using Makefiles, instead of Xcode project file on Darwin
	sed -i -e '/darwin/s/xcode/make/' build/gyp/pylib/gyp/__init__.py || die
	# don't refuse to build shared_libs because we build somewhere else
	sed -i \
		-e '/params\.get.*mac.*darwin.*linux/s/mac/darwin/' \
		-e "/if GetFlavor(params) == 'mac':/s/mac/darwin/" \
		-e "/^  if flavor == 'mac':/s/mac/darwin/" \
		build/gyp/pylib/gyp/generator/make.py || die
	# make sure our v8.dylib doesn't end up being empty and give it a proper
	# install_name (soname)
	sed -i \
		-e '/^LINK_COMMANDS_MAC =/,/^SHARED_HEADER =/s#-shared#-dynamiclib -all_load -install_name '"${EPREFIX}/usr/$(get_libdir)/libv8$(get_libname $(get_version_component_range 1-3))"'#' \
		build/gyp/pylib/gyp/generator/make.py || die
}

src_compile() {
	tc-export AR CC CXX RANLIB
	export LINK="${CXX}"

	# Use target arch detection logic from bug #354601.
	case ${CHOST} in
		i?86-*) myarch=ia32 ;;
		x86_64-*)
			if [[ $ABI = x86 ]] ; then
				myarch=ia32
			else
				myarch=x64
			fi ;;
		arm*-*) myarch=arm ;;
		*) die "Unrecognized CHOST: ${CHOST}"
	esac
	mytarget=${myarch}.release

	soname_version="$(get_version_component_range 1-3)"

	local snapshot=on
	host-is-pax && snapshot=off

	# TODO: Add console=readline option once implemented upstream
	# http://code.google.com/p/v8/issues/detail?id=1781

	emake V=1 \
		library=shared \
		werror=no \
		soname_version=${soname_version} \
		snapshot=${snapshot} \
		${mytarget} || die

	pax-mark m out/${mytarget}/{cctest,d8,shell} || die
}

src_test() {
	local arg testjobs
	for arg in ${MAKEOPTS}; do
		case ${arg} in
			-j*) testjobs=${arg#-j} ;;
			--jobs=*) testjobs=${arg#--jobs=} ;;
		esac
	done

	tools/test-wrapper-gypbuild.py \
		-j${testjobs:-1} \
		--arch-and-mode=${mytarget} \
		--no-presubmit \
		--progress=dots || die
}

src_install() {
	insinto /usr
	doins -r include || die

	dobin out/${mytarget}/d8 || die

	if [[ ${CHOST} == *-darwin* ]] ; then
		# buildsystem is too horrific to get this built correctly
		mv out/${mytarget}/lib.target/libv8.so.${soname_version} \
			out/${mytarget}/lib.target/libv8$(get_libname ${soname_version}) || die
	fi

	dolib out/${mytarget}/lib.target/libv8$(get_libname ${soname_version}) || die
	dosym libv8$(get_libname ${soname_version}) /usr/$(get_libdir)/libv8$(get_libname) || die

	dodoc AUTHORS ChangeLog || die
}

pkg_preinst() {
	preserved_libs=()
	local baselib candidate

	eshopts_push -s nullglob

	for candidate in "${EROOT}usr/$(get_libdir)"/libv8$(get_libname).*; do
		baselib=${candidate##*/}
		if [[ ! -e "${ED}usr/$(get_libdir)/${baselib}" ]]; then
			preserved_libs+=( "${EPREFIX}/usr/$(get_libdir)/${baselib}" )
		fi
	done

	eshopts_pop

	if [[ ${#preserved_libs[@]} -gt 0 ]]; then
		preserve_old_lib "${preserved_libs[@]}"
	fi
}

pkg_postinst() {
	if [[ ${#preserved_libs[@]} -gt 0 ]]; then
		preserve_old_lib_notify "${preserved_libs[@]}"
	fi
}
