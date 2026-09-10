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

# 0.3.25a is 0.3.25 rebuilt against pandoc 3.11: upstream changed only build
# pins between the two tags, and the binary still reports v0.3.25. Both are
# built with pandoc-types 1.23.1.2, so the filter's JSON interface is the
# same under pandoc 3.10.1 and 3.11.
#
# pandoc-crossref compares its build-time pandoc version with the one running
# it and, on any mismatch, prints a "not supported" warning but still
# resolves references. 0.3.25 pinned ~pandoc-bin-3.10.1 to avoid the warning,
# and that broke dependency resolution instead: pandoc-bin is normally only a
# dependency, not in the world file, so once ::gentoo carried a newer
# pandoc-bin, a deep @world update resolved the || group through >=pandoc-3,
# i.e. pandoc-cli and dev-lang/ghc built from source. A lower bound keeps the
# binary alternative across pandoc-bin bumps; a mismatch costs only the
# warning.
# verified 2026-09-10
RDEPEND="
|| ( >=app-text/pandoc-bin-3.10.1 >=app-text/pandoc-3 )
"

src_install() {
	exeinto /usr/bin
	newexe pandoc-crossref pandoc-crossref
	newman pandoc-crossref.1 pandoc-crossref.1
}
