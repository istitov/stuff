# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Object Oriented MicroMagnetic Framework"
HOMEPAGE="https://math.nist.gov/oommf/"
SRC_URI="https://math.nist.gov/oommf/dist/${PN}21a2_20250930.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="HPND"
SLOT="2.1"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc"

DEPEND="
dev-lang/tcl:=
dev-lang/tk:="
RDEPEND="${DEPEND}"

src_compile() {
	tclsh oommf.tcl pimake distclean
	tclsh oommf.tcl pimake upgrade
	tclsh oommf.tcl pimake
}

src_install()
{
	tclsh oommf.tcl pimake objclean

	use doc && dodoc "./doc/userguide/userguide.pdf"
	use doc && dodoc "./doc/progman/progman.pdf"
	rm -rf "./doc"
	dodoc README.md LICENSE.md

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
