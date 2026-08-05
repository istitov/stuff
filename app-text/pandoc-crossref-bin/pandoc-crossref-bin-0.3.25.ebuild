# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="Pandoc filter for cross-references"
HOMEPAGE="https://github.com/lierdakil/pandoc-crossref"
SRC_URI="https://github.com/lierdakil/pandoc-crossref/releases/download/v${PV}/pandoc-crossref-Linux-X64.tar.xz -> ${P}.tar.xz"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64"

# The Linux binary is compiled against pandoc 3.10.1 and pandoc-crossref does
# an exact pandoc-version string check that warns "not supported" on any
# mismatch. ::gentoo now carries pandoc-bin-3.10.1, so pin it for an exact
# match (no stderr warning); the source >=pandoc-3 fallback may warn on a
# version mismatch. verified 2026-08-05
RDEPEND="
|| ( ~app-text/pandoc-bin-3.10.1 >=app-text/pandoc-3 )
"

src_install() {
	exeinto /usr/bin
	newexe pandoc-crossref pandoc-crossref
	newman pandoc-crossref.1 pandoc-crossref.1
}
