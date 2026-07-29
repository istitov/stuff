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

# The Linux binary is compiled against pandoc 3.10.1, and pandoc-crossref
# does an exact pandoc-version string check that warns "not supported" on
# any mismatch. ::gentoo carries no pandoc-bin-3.10.1, so pin the nearest
# 3.10: cross-references resolve correctly (shared pandoc-types 1.23.1.x,
# JSON api [1,23,1], smoke-tested), but the stderr warning is expected
# until pandoc-bin-3.10.1 lands. verified 2026-07-29
RDEPEND="
|| ( ~app-text/pandoc-bin-3.10 >=app-text/pandoc-3 )
"

src_install() {
	exeinto /usr/bin
	newexe pandoc-crossref pandoc-crossref
	newman pandoc-crossref.1 pandoc-crossref.1
}
