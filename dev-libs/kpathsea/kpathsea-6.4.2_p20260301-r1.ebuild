# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit texlive-common libtool prefix tmpfiles

MY_SOURCE_FILE="texlive-${PV#*_p}-source.tar.xz"

DESCRIPTION="Path searching library for TeX-related files"
HOMEPAGE="https://tug.org/texlive/"
# Portage expansion cannot conveniently extract the year from _pYYYYMMDD;
# update the hardcoded historic URL annually.
SRC_URI="
	https://mirrors.ctan.org/systems/texlive/Source/${MY_SOURCE_FILE}
	https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2026/${MY_SOURCE_FILE}
	https://dev.gentoo.org/~flow/distfiles/texlive/${MY_SOURCE_FILE}
"

TL_REVISION=79498
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
	# Upstream A-Z/a-z regexes assume ASCII collation (bug #347798).
	export LC_ALL=C

	# Large-file support breaks 32-bit big-endian systems.
	econf \
		--disable-largefile \
		"$(use_enable static-libs static)"
}

src_install() {
	emake DESTDIR="${D}" web2cdir="${EPREFIX}/usr/share/texmf-dist/web2c" install
	find "${D}" -name '*.la' -delete || die

	dodir /usr/share
	cp -pR "${WORKDIR}"/texmf-dist "${ED}/usr/share/" || die "failed to install texmf trees"

	dodir /etc/texmf/{fmtutil.d,texmf.d}

	# Replace the default with texmf-update's generated configuration.
	rm -f "${ED}${TEXMF_PATH}/web2c/texmf.cnf" || die

	# Carry Gentoo's five configuration files locally because their old distfile
	# vanished. Decompress 10standardpaths.cnf to stay below SizeViolation.
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

	# texmf-update regenerates fmtutil.cnf.
	rm -f "${ED}${TEXMF_PATH}/web2c/fmtutil.cnf" || die

	dosym ../../../../etc/texmf/web2c/fmtutil.cnf ${TEXMF_PATH}/web2c/fmtutil.cnf
	dosym ../../../../etc/texmf/web2c/texmf.cnf ${TEXMF_PATH}/web2c/texmf.cnf

	newsbin "${S}/texmf-update" texmf-update

	# Runtime formats are written here.
	keepdir /var/lib/texmf

	dodoc ChangeLog NEWS PROJECTS README

	# Default configuration requires world-writable state (bug #266680).
	dotmpfiles "${FILESDIR}"/kpathsea.conf
}

pkg_postinst() {
	tmpfiles_process kpathsea.conf
	etexmf-update
}

pkg_postrm() {
	etexmf-update
}
