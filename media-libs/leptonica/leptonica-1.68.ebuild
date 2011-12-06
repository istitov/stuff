# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit autotools multilib

#MY_P="leptonlib-${PV}"
DESCRIPTION="An open source C library for image processing and analysis"
HOMEPAGE="http://www.leptonica.com/"
SRC_URI="http://www.leptonica.com/source/${P}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SLOT="0"

DEPEND="virtual/jpeg
	media-libs/giflib
	media-libs/tiff"
RDEPEND="${DEPEND}"

#S=${WORKDIR}/${MY_P}

DOCS=( README version-notes )

src_prepare() {
	epatch "${FILESDIR}/${P}-pngio.patch"
	# We need a fake m4 dir, as setting AT_M4DIR to
	# an empty value does not make eAT forget to
	# add "-I m4" to the AT commands
	#mkdir m4
	eautoreconf

	# unhtmlize docs (they're just one big <pre/>s)
	local docf
	for _docf in ${DOCS[@]}; do
		awk '/<\/pre>/{s--} {if (s) print $0} /<pre>/{s++}' \
			${_docf}.html > ${_docf} || die 'awk failed.'
	done
}

src_install() {
	emake DESTDIR="${D}" install || die 'emake install failed.'
	dodoc ${DOCS[@]} || die 'dodoc failed.'

	# remove .la file, it was needed only to build shared lib
	rm "${D}"/usr/$(get_libdir)/liblept.la || die 'rm failed.'

	# remove fake m4 dir
	rm m4/*
	rmdir m4
}
