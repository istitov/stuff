# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# http://libjpeg-turbo.svn.sourceforge.net/viewvc/libjpeg-turbo/branches/1.2.x/?view=tar

EAPI=7

unset _inherits

JPEG_ABI=8

inherit ${_inherits} java-pkg-opt-2 libtool toolchain-funcs subversion autotools

DESCRIPTION="MMX, SSE, and SSE2 SIMD accelerated JPEG library"
HOMEPAGE="https://libjpeg-turbo.virtualgl.org/ https://sourceforge.net/projects/libjpeg-turbo/"
ESVN_REPO_URI="svn://svn.code.sf.net/p/libjpeg-turbo/code/trunk"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="java static-libs"

ASM_DEPEND="|| ( dev-lang/nasm dev-lang/yasm )"
COMMON_DEPEND="!media-libs/jpeg:0"
RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.5 )"
DEPEND="${COMMON_DEPEND}
	amd64? ( ${ASM_DEPEND} )
	x86? ( ${ASM_DEPEND} )
	amd64-linux? ( ${ASM_DEPEND} )
	x86-linux? ( ${ASM_DEPEND} )
	java? ( >=virtual/jdk-1.5 )"

DOCS="*.txt change.log example.c README"

src_prepare() {
	if [[ -x ./configure ]]; then
		elibtoolize
	else
		eautoreconf
	fi
	java-pkg-opt-2_src_prepare
}

src_configure() {
	if use java; then
		export JAVACFLAGS="$(java-pkg_javac-args)"
		export JNI_CFLAGS="$(java-pkg_get-jni-cflags)"
	fi

	econf \
		$(use_enable static-libs static) \
		--with-jpeg${JPEG_ABI} \
		$(use_with java)
}

src_compile() {
	local _java_makeopts
	use java && _java_makeopts="-j1"
	emake ${_java_makeopts}

	emake CC="$(tc-getCC)" CFLAGS="${LDFLAGS} ${CFLAGS}"
	popd >/dev/null
	eend $?
}

src_test() {
	emake test
}

src_install() {
	default
	find "${ED}"usr -name '*.la' -exec rm -f {} +

	insinto /usr/share/doc/${PF}/html
	doins -r doc/html/*

	if use java; then
		insinto /usr/share/doc/${PF}/html/java
		doins -r java/doc/*
		newdoc java/README README.java

		rm -rf "${ED}"usr/classes
		java-pkg_dojar java/turbojpeg.jar
	fi

	emake \
		DESTDIR="${D}" prefix="${EPREFIX}"/usr \
		INSTALL="install -m755" INSTALLDIR="install -d -m755" \
		install
	popd >/dev/null
	eend $?
}
