# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

DESCRIPTION="The Object Oriented MicroMagnetic Framework"
HOMEPAGE="https://math.nist.gov/oommf/"
SRC_URI="https://math.nist.gov/oommf/dist/${PN}12b4_20200930.tar.gz"
S="${WORKDIR}/${PN}"

# NIST's code is not subject to copyright in the US; ::gentoo labels NIST
# software public-domain (sci-libs/tnt, sci-mathematics/dataplot).
# The bundled 2dpbc OXS extension carries a GPL-3 LICENSE.
# verified 2026-10-03
LICENSE="GPL-3 public-domain"
SLOT="1.2"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc"

DEPEND="
dev-lang/tcl:=
dev-lang/tk:="
RDEPEND="${DEPEND}"

src_compile() {
	# pimake's upgrade target only clears files left by an older in-place
	# install. On a fresh tree it removes nothing, and the build writes the
	# same tclIndex entries itself, so it is skipped. verified 2026-10-03
	tclsh oommf.tcl pimake distclean || die
	tclsh oommf.tcl pimake || die
	# Here rather than in src_install: OOMMF 2.x refuses to run as root.
	tclsh oommf.tcl pimake objclean || die
}

src_install()
{
	use doc && dodoc "./doc/userguide/userguide.pdf"
	use doc && dodoc "./doc/progman/progman.pdf"
	rm -rf "./doc"
	dodoc README

	# Each series gets its own tree and launcher, so the slots install side
	# by side; they all used /opt/oommf and /opt/bin/oommf.sh before.
	local oommf_dir="/opt/${PN}-${SLOT}"
	dodir "${oommf_dir}"
	mv * "${ED}${oommf_dir}" || die

	exeinto /opt/bin
	newexe - "${PN}-${SLOT}" <<-EOF
		#!/bin/sh
		exec tclsh "${EPREFIX}${oommf_dir}/oommf.tcl" "\$@"
	EOF
}

pkg_postinst() {
	elog "Start OOMMF ${SLOT} with ${PN}-${SLOT}; it lives in"
	elog "${EPREFIX}/opt/${PN}-${SLOT}, so other OOMMF series can be installed"
	elog "alongside it. The former /opt/bin/oommf.sh launcher is gone."
}
