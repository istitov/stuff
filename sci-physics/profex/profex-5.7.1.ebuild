# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop qmake-utils xdg

DESCRIPTION="Open source XRD and Rietveld refinement (Qt6)"
HOMEPAGE="https://www.profex-xrd.org"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2026/07/${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="bgmn"

# Upstream's Qt 6 build expects bundled zlib, QuaZIP, and ALGLIB projects.
RDEPEND="
	bgmn? ( sci-physics/bgmn )
	dev-qt/qtbase:6=[concurrent,gui,network,sql,widgets,xml]
	dev-qt/qtdeclarative:6
	dev-qt/qtimageformats:6
	dev-qt/qtsvg:6
"
DEPEND="${RDEPEND}"
BDEPEND="dev-qt/qtbase:6"

src_prepare() {
	default
	# Drop pxcifindex, listed by qmake but absent from the tarball.
	# verified 2026-07-06
	sed -i -e '/cmdtools\/pxcifindex/d' -e '/pxcifindex\.depends/d' \
		profex.pro || die
}

src_configure() {
	eqmake6 -r profex.pro
}

src_install() {
	# The qmake tree has no install rules; install all generated tools.
	dobin bin/*

	# Version is the desktop-file format, not the application version.
	sed -i -e 's/^Version=.*/Version=1.5/' profex5.desktop || die
	domenu profex5.desktop

	insinto /usr/share/metainfo
	doins org.profex_xrd.Profex.appdata.xml

	dodoc changelog.txt
}

pkg_postinst() {
	xdg_pkg_postinst

	if ! use bgmn; then
		elog "Install ${PN} with USE=bgmn to use the BGMN refinement backend."
		elog "Without it, the data viewer, conversion tools, peak fitting, and"
		elog "support for an externally installed FullProf backend remain available."
	fi
}
