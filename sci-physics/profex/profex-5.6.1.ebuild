# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop qmake-utils

DESCRIPTION="Open source XRD and Rietveld refinement (Qt6)"
HOMEPAGE="https://www.profex-xrd.org"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2025/11/${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

# zlib, quazip and alglib are bundled and built via profex's own subdir
# qmake projects; building against system copies would require
# significant patching and the upstream Qt6 port expects the bundles.
RDEPEND="
	sci-physics/bgmn
	dev-qt/qt5compat:6
	dev-qt/qtbase:6=[concurrent,gui,network,sql,widgets,xml]
	dev-qt/qtdeclarative:6
	dev-qt/qtimageformats:6
	dev-qt/qtsvg:6
"
DEPEND="${RDEPEND}"
BDEPEND="dev-qt/qtbase:6"

src_configure() {
	eqmake6 -r profex.pro
}

src_install() {
	# Upstream's qmake tree has no install rules. The resulting
	# bin/ holds the main GUI (profex), module GUIs shipped as
	# separate binaries with profex* prefixes (profexed, profexsc,
	# profexst, profexwp, ...), and a handful of px* command-line
	# tools. Install them all.
	dobin bin/*

	# Upstream sets Version= to the app version (5.1.0) instead of
	# the Desktop Entry spec version; trips desktop-file-validate.
	sed -i -e 's/^Version=.*/Version=1.5/' profex5.desktop || die
	domenu profex5.desktop

	insinto /usr/share/metainfo
	doins org.profex_xrd.Profex.appdata.xml

	dodoc changelog.txt
}
