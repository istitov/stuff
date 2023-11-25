# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# http://libjpeg-turbo.svn.sourceforge.net/viewvc/libjpeg-turbo/branches/1.2.x/?view=tar

EAPI=8

inherit cmake-multilib java-pkg-opt-2 git-r3

DESCRIPTION="MMX, SSE, and SSE2 SIMD accelerated JPEG library"
HOMEPAGE="https://libjpeg-turbo.virtualgl.org/ https://sourceforge.net/projects/libjpeg-turbo/"
EGIT_REPO_URI="https://github.com/libjpeg-turbo/libjpeg-turbo"

LICENSE="BSD IJG ZLIB"
SLOT="0/0.2"
IUSE="java static-libs cpu_flags_arm_neon"

ASM_DEPEND="|| ( dev-lang/nasm dev-lang/yasm )"
COMMON_DEPEND=""

BDEPEND=">=dev-util/cmake-3.16.5
	amd64? ( ${ASM_DEPEND} )
	x86? ( ${ASM_DEPEND} )
	amd64-linux? ( ${ASM_DEPEND} )
	x86-linux? ( ${ASM_DEPEND} )
	x64-macos? ( ${ASM_DEPEND} )
	x64-cygwin? ( ${ASM_DEPEND} )"

DEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.8:*[-headless-awt] )"

RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.8:* )"

MULTILIB_WRAPPED_HEADERS=( /usr/include/jconfig.h )

#DOCS="*.txt change.log example.c README"

src_prepare() {
	cmake_src_prepare
	java-pkg-opt-2_src_prepare
}

multilib_src_configure() {
	if multilib_is_native_abi && use java ; then
		export JAVACFLAGS="$(java-pkg_javac-args)"
		export JNI_CFLAGS="$(java-pkg_get-jni-cflags)"
	fi

	local mycmakeargs=(
		-DCMAKE_INSTALL_DEFAULT_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-DENABLE_STATIC="$(usex static-libs)"
		-DWITH_JAVA="$(multilib_native_usex java)"
		-DWITH_MEM_SRCDST=ON
	)

	# Avoid ARM ABI issues by disabling SIMD for CPUs without NEON. #792810
	if use arm || use arm64; then
		mycmakeargs+=(
			-DWITH_SIMD=$(usex cpu_flags_arm_neon)
			-DNEON_INTRINSICS=$(usex cpu_flags_arm_neon)
		)
	fi

	# We should tell the test suite which floating-point flavor we are
	# expecting: https://github.com/libjpeg-turbo/libjpeg-turbo/issues/597
	# For now, mark loong as fp-contract.
	if use loong; then
		mycmakeargs+=(
			-DFLOATTEST=fp-contract
		)
	fi

	# mostly for Prefix, ensure that we use our yasm if installed and
	# not pick up host-provided nasm
	if has_version -b dev-lang/yasm && ! has_version -b dev-lang/nasm; then
		mycmakeargs+=(
			-DCMAKE_ASM_NASM_COMPILER=$(type -P yasm)
		)
	fi

	cmake_src_configure
}

multilib_src_install() {
	cmake_src_install

	if multilib_is_native_abi && use java ; then
		rm -rf "${ED}"/usr/classes || die
		java-pkg_dojar java/turbojpeg.jar
	fi
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die

	local -a DOCS=( README.md ChangeLog.md )
	einstalldocs

	docinto html
	dodoc -r "${S}"/doc/html/.

	if use java; then
		docinto html/java
		dodoc -r "${S}"/java/doc/.
		newdoc "${S}"/java/README README.java
	fi
}
