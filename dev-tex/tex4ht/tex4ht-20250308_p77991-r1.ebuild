# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit latex-package toolchain-funcs java-pkg-opt-2 flag-o-matic readme.gentoo-r1

MY_P_TEXLIVE="${PN}.r$(ver_cut 3).tar.xz"
MY_P_TEXLIVE_DOC="${PN}.doc.r$(ver_cut 3).tar.xz"
MY_P_TEXLIVE_SRC="${PN}.source.r$(ver_cut 3).tar.xz"

# The postprocessor engine (tex4ht.c/t4ht.c + java) is built from the TeX
# Live source tarball's texk/tex4htk/ tree -- the same durable, mirror-hosted
# source that kpathsea/ptexenc/dvipsk pin -- rather than a separately-hosted
# tex4ht-sources-<N> bundle. This keeps the engine in lockstep with the
# TL2025 runtime data and needs no extra distfile hosting.
MY_SOURCE_FILE="texlive-${PV%_p*}-source.tar.xz"
TEX4HTK_SUBDIR="texlive-${PV%_p*}-source/texk/tex4htk"

DESCRIPTION="Converts (La)TeX to (X)HTML, XML and OO.org"
HOMEPAGE="
	https://tug.org/tex4ht/
	https://puszcza.gnu.org.ua/projects/tex4ht/
"
# 2025 hardcoded in the historic TL-data URL; bump on TL2027 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/${MY_SOURCE_FILE}
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/${MY_SOURCE_FILE}
	https://dev.gentoo.org/~flow/distfiles/texlive/${MY_SOURCE_FILE}
	https://mirrors.ctan.org/systems/texlive/tlnet/archive/${MY_P_TEXLIVE}
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/archive/${MY_P_TEXLIVE}
	https://dev.gentoo.org/~flow/distfiles/texlive/${MY_P_TEXLIVE}
	source? (
		https://mirrors.ctan.org/systems/texlive/tlnet/archive/${MY_P_TEXLIVE_SRC}
		https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/archive/${MY_P_TEXLIVE_SRC}
		https://dev.gentoo.org/~flow/distfiles/texlive/${MY_P_TEXLIVE_SRC}
	)
	doc? (
		https://mirrors.ctan.org/systems/texlive/tlnet/archive/${MY_P_TEXLIVE_DOC}
		https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/tlnet-final/archive/${MY_P_TEXLIVE_DOC}
		https://dev.gentoo.org/~flow/distfiles/texlive/${MY_P_TEXLIVE_DOC}
	)
"
S="${WORKDIR}"

LICENSE="LPPL-1.2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="doc java source"

COMMON_DEPEND="
	dev-libs/kpathsea:=
"

RDEPEND="
	${COMMON_DEPEND}
	app-text/ghostscript-gpl
	dev-lang/perl
	dev-texlive/texlive-binextra
	dev-texlive/texlive-luatex
	virtual/imagemagick-tools
	java? ( >=virtual/jre-1.8:* )
"

DEPEND="
	${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.8:* )
"

BDEPEND="virtual/pkgconfig"

# No longtable-caption patch. ::gentoo backported the upstream fix
# (svn r1745/r1747, 2025-10) onto its TL2024 tex4ht data, but that
# patch is cut against the TL2024 longtable.4ht/html4.4ht layout and
# does not apply to TL2025's evolved r77991 data. The fix only affects
# HTML validity of longtable captions (not the build or core
# function); re-cutting it against r77991 is out of scope. TL2026 data
# (r79447) carries the fix upstream.

src_prepare() {
	mv texmf-dist texmf || die
	default
	cd "${S}/texmf/tex4ht/base/unix" || die
	sed -i \
		-e "s#~/tex4ht.dir#${EPREFIX}/usr/share#" \
		-e "s#tpath/tex/texmf/fonts/tfm/!#t${EPREFIX}/usr/share/texmf-dist/fonts/tfm/!\nt${EPREFIX}/usr/local/share/texmf/fonts/tfm/!\nt${EPREFIX}/var/cache/fonts/tfm/!\nt${EPREFIX}${TEXMF}/fonts/tfm/!#" \
		-e "s#%%~#${EPREFIX}${TEXMF}#g" \
		tex4ht.env \
		|| die "sed of tex4ht.env failed"

	einfo "Removing precompiled java stuff"
	rm "${S}/texmf/tex4ht/bin/tex4ht.jar" || die
}

src_compile() {
	has_version '>=dev-libs/kpathsea-6.2.1' \
		&& append-cppflags "$($(tc-getPKG_CONFIG) --cflags kpathsea)"

	pushd "${S}/${TEX4HTK_SUBDIR}" > /dev/null || die
	einfo "Compiling postprocessor sources..."
	for f in tex4ht t4ht; do
		$(tc-getCC) ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o $f $f.c \
			-DENVFILE="\"${EPREFIX}${TEXMF}/tex4ht/base/tex4ht.env\"" \
			-DANSI -DHAVE_DIRENT_H -DKPATHSEA -lkpathsea \
			|| die "Compiling $f failed"
	done
	popd > /dev/null || die

	if use java; then
		einfo "Compiling java files..."
		# TL source layout: engine java lives under java/, java/xtpipes/
		# and java/xtpipes/util/, with xv4ht.java at the tex4htk root.
		# Stage them together and jar as the runtime expects.
		cp "${S}/${TEX4HTK_SUBDIR}/xv4ht.java" "${S}/${TEX4HTK_SUBDIR}/java/" || die
		pushd "${S}/${TEX4HTK_SUBDIR}/java" > /dev/null || die
		ejavac *.java xtpipes/*.java xtpipes/util/*.java || die "javac failed"
		rm *.java xtpipes/*.java xtpipes/util/*.java || die
		jar -cf "${S}/${PN}.jar" * || die "failed to create jar"
		popd > /dev/null || die
	fi
}

src_install() {
	# install the binaries
	dobin "${S}/${TEX4HTK_SUBDIR}/tex4ht" "${S}/${TEX4HTK_SUBDIR}/t4ht"
	# install the mk4ht driver
	newbin texmf/scripts/tex4ht/mk4ht.pl mk4ht

	# install the .4ht scripts
	insinto ${TEXMF}/tex/generic/tex4ht
	doins "${S}"/texmf/tex/generic/tex4ht/*

	if use doc; then
		# install the documentation
		insinto ${TEXMF}/doc/generic/tex4ht
		doins "${S}"/texmf/doc/generic/tex4ht/*
	fi

	if use source; then
		insinto ${TEXMF}/source/generic/tex4ht
		doins "${S}"/texmf/source/generic/tex4ht/*
	fi

	# install the special htf fonts
	insinto ${TEXMF}/tex4ht
	doins -r "${S}/texmf/tex4ht/ht-fonts"

	if use java; then
		# install the java files
		doins -r "${S}/texmf/tex4ht/bin"
		java-pkg_jarinto ${TEXMF}/tex4ht/bin
		java-pkg_dojar "${S}/${PN}.jar"
	fi

	# install the .4xt files
	doins -r "${S}/texmf/tex4ht/xtpipes"

	# install the env file
	insinto ${TEXMF}/tex4ht/base
	newins "${S}/texmf/tex4ht/base/unix/tex4ht.env" tex4ht.env

	insinto /etc/texmf/texmf.d
	doins "${FILESDIR}/50tex4ht.cnf"

	insinto ${TEXMF}/tex/generic/${PN}
	insopts -m755
	local script_name
	for script_name in htlatex.sh htmex.sh ht.sh httexi.sh httex.sh htxelatex.sh htxetex.sh xhlatex.sh; do
		newins texmf/scripts/tex4ht/"${script_name}" "${script_name%.*}"
	done

	local DOC_CONTENTS="In order to avoid collisions with multiple packages,
		we are not installing the scripts in /usr/bin any more.
		If you want to use, say, htlatex, you can use 'mk4ht htlatex file'."
	use java || DOC_CONTENTS+="\n\nODF converters (oolatex & friends)
		require the java use flag."
	readme.gentoo_create_doc
}

pkg_postinst() {
	latex-package_pkg_postinst
	readme.gentoo_print_elog
}
