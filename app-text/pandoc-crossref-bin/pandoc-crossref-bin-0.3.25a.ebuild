# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="Pandoc filter for cross-references"
HOMEPAGE="https://github.com/lierdakil/pandoc-crossref"
SRC_URI="
	amd64? (
		https://github.com/lierdakil/pandoc-crossref/releases/download/v${PV}/pandoc-crossref-Linux-X64.tar.xz
			-> ${P}-amd64.tar.xz
	)
	arm64? (
		https://github.com/lierdakil/pandoc-crossref/releases/download/v${PV}/pandoc-crossref-Linux-ARM64.tar.xz
			-> ${P}-arm64.tar.xz
	)
"

S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# 0.3.25a rebuilds 0.3.25 for pandoc 3.11 without changing its JSON interface.
# The filter only warns on pandoc version mismatch. A lower bound keeps
# pandoc-bin viable after bumps; an exact pin instead makes Portage select the
# source pandoc/GHC stack. Verified 2026-09-10.
RDEPEND="
|| ( >=app-text/pandoc-bin-3.10.1 >=app-text/pandoc-3 )
"

src_install() {
	exeinto /usr/bin
	newexe pandoc-crossref pandoc-crossref
	newman pandoc-crossref.1 pandoc-crossref.1
}
