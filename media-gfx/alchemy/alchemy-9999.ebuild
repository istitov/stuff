# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils fdo-mime java-pkg-2 java-ant-2 versionator subversion

DESCRIPTION="Drawing program used for creating shapes, with interactivity and creativity as main focus."
HOMEPAGE="http://al.chemy.org/"
ESVN_REPO_URI="http://svn.al.chemy.org/svn"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${RDEPEND}
	dev-util/desktop-file-utils
	>=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

src_prepare() {
	epatch "${FILESDIR}/${P}-build.xml-install.patch"
}

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_BUILD_XML="./Alchemy/build.xml"


src_compile() {
	local mem
	use amd64 && mem="320"
	use x86   && mem="192"
	use ppc   && mem="192"
	use ppc64 && mem="256"
	export ANT_OPTS="-Xmx${mem}m"
	java-pkg-2_src_compile
}


src_install() {
	java-pkg_dojar Alchemy/dist/Alchemy.jar
	insinto /usr/share/${PN}
	doins -r "${WORKDIR}"/${P}/Alchemy/dist/Alchemy/*

	java-pkg_dolauncher "${PN}" \
		--pwd /usr/share/"${PN}"

	newicon "${WORKDIR}"/${P}/Alchemy/src/org/alchemy/data/alchemy-logo64.png alchemy.png
	domenu "${FILESDIR}/${PN}.desktop"

}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

