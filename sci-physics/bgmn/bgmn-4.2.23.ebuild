# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Open source XRD and Rietveld refiniment"
HOMEPAGE="https://www.profex-xrd.org"
SRC_URI="https://www.profex-xrd.org/wp-content/uploads/2017/12/${P}-x86_64.tar.gz"

#https://www.profex-xrd.org/wp-content/uploads/2022/01/cod-220114.zip -> cod.zip
#https://www.profex-xrd.org/wp-content/uploads/2021/08/BGMN-Templates-210815.tar.gz -> bgmn_templates.tar.gz
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"

DEPEND="${RDEPEND}"
RESTRICT="!test? ( test )"
S="${WORKDIR}/${PN}-${PV}"

src_install() {
	dobin "${S}"/bgmn
	dobin "${S}"/makegeq
	dobin "${S}"/geomet
	dobin "${S}"/teil
	dobin "${S}"/eflech
	default
}
