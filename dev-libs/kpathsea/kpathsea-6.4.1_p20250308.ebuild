# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit texlive-common libtool prefix tmpfiles

MY_SOURCE_FILE="texlive-${PV#*_p}-source.tar.xz"

DESCRIPTION="Path searching library for TeX-related files"
HOMEPAGE="https://tug.org/texlive/"
# 2025 hardcoded in the historic URL because PV's "_p<YYYYMMDD>" date
# format makes the four-digit year non-trivial to extract via Portage
# parameter expansion at SRC_URI time. Bump on TL2026 adoption.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/${MY_SOURCE_FILE}
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2025/${MY_SOURCE_FILE}
	https://dev.gentoo.org/~flow/distfiles/texlive/${MY_SOURCE_FILE}
"

TL_REVISION=75425
EXTRA_TL_MODULES="kpathsea.r${TL_REVISION}"
EXTRA_TL_DOC_MODULES="kpathsea.doc.r${TL_REVISION}"

texlive-common_append_to_src_uri EXTRA_TL_MODULES

SRC_URI="${SRC_URI} doc? ( "
texlive-common_append_to_src_uri EXTRA_TL_DOC_MODULES
SRC_URI="${SRC_URI} ) "

S=${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}
LICENSE="LGPL-2.1"
SLOT="0/${PV%_p*}"

KEYWORDS="~amd64 ~arm64"
IUSE="doc static-libs"

TEXMF_PATH=/usr/share/texmf-dist

# c23 patch dropped: backport from TL trunk r74888 (Apr 2025) is already
# in TL2025 source (kpathsea revision 75425 > 74888). musl patch kept;
# still applicable to TL2025 getopt.[ch] shipped here.
PATCHES=(
	"${FILESDIR}"/kpathsea-getopt-musl.patch
)

src_prepare() {
	default
	cd "${WORKDIR}/texlive-${PV#*_p}-source" || die
	S="${WORKDIR}/texlive-${PV#*_p}-source" elibtoolize
	cp "${FILESDIR}/texmf-update-r2" "${S}"/texmf-update || die
	eprefixify "${S}"/texmf-update
}

src_configure() {
	# Too many regexps use A-Z a-z constructs, what causes problems with locales
	# that don't have the same alphabetical order than ascii. Bug #347798
	# So we set LC_ALL to C in order to avoid problems.
	export LC_ALL=C

	# Disable largefile because it seems to cause problems on big endian 32 bits
	# systems...
	econf \
		--disable-largefile \
		"$(use_enable static-libs static)"
}

src_install() {
	emake DESTDIR="${D}" web2cdir="${EPREFIX}/usr/share/texmf-dist/web2c" install
	find "${D}" -name '*.la' -delete || die

	dodir /usr/share # just in case
	cp -pR "${WORKDIR}"/texmf-dist "${ED}/usr/share/" || die "failed to install texmf trees"

	# Take care of fmtutil.cnf and texmf.cnf
	dodir /etc/texmf/{fmtutil.d,texmf.d}

	# Remove default texmf.cnf to ship our own, greatly based on texlive dvd's
	# texmf.cnf
	# It will also be generated from /etc/texmf/texmf.d files by texmf-update
	rm -f "${ED}${TEXMF_PATH}/web2c/texmf.cnf" || die

	# Vendored from ::gentoo's kpathsea-texmf.d-11 distfile (installed
	# verbatim from /etc/texmf/texmf.d). Sam's tarball isn't on flow's
	# distfile mirror anymore; carrying the 5 *.cnf files directly is
	# cleaner than chasing the distfile location. 10standardpaths.cnf
	# is xz-compressed in files/ to stay under pkgcheck SizeViolation;
	# decompress all .cnf.xz to ${T}/texmf.d/ before doins.
	local cnf_stage="${T}/texmf.d"
	mkdir -p "${cnf_stage}" || die
	local cnf
	for cnf in "${FILESDIR}/texmf.d/"*.cnf; do
		[[ -f ${cnf} ]] || continue
		cp "${cnf}" "${cnf_stage}/" || die
	done
	for cnf in "${FILESDIR}/texmf.d/"*.cnf.xz; do
		[[ -f ${cnf} ]] || continue
		xz -dkc "${cnf}" > "${cnf_stage}/$(basename "${cnf}" .xz)" || die
	done
	insinto /etc/texmf/texmf.d
	doins "${cnf_stage}/"*.cnf

	# Remove fmtutil.cnf, it will be regenerated from /etc/texmf/fmtutil.d files
	# by texmf-update
	rm -f "${ED}${TEXMF_PATH}/web2c/fmtutil.cnf" || die

	dosym ../../../../etc/texmf/web2c/fmtutil.cnf ${TEXMF_PATH}/web2c/fmtutil.cnf
	dosym ../../../../etc/texmf/web2c/texmf.cnf ${TEXMF_PATH}/web2c/texmf.cnf

	newsbin "${S}/texmf-update" texmf-update

	# Keep it as that's where the formats will go
	keepdir /var/lib/texmf

	dodoc ChangeLog NEWS PROJECTS README

	# The default configuration expects it to be world writable, bug #266680
	# People can still change it with texconfig though.
	dotmpfiles "${FILESDIR}"/kpathsea.conf
}

pkg_postinst() {
	tmpfiles_process kpathsea.conf
	etexmf-update
}

pkg_postrm() {
	etexmf-update
}
