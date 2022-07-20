# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Atomistic simulation of magnetic nanomaterials made easy."
HOMEPAGE="http://vampire.york.ac.uk/"
SRC_URI="https://github.com/richard-evans/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
DOC_SRC_URI="http://vampire.york.ac.uk/resources/vampire-manual.pdf"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
#IUSE="doc cuda debug mpi"
IUSE="doc"
DEPEND=""
RDEPEND="${DEPEND}"

src_prepare(){
	use doc && wget -c "${DOC_SRC_URI}" -O "${PN}-${PV}-manual.pdf"
}

src_install(){
	dosbin vampire
	use doc && dodoc "${PN}-${PV}-manual.pdf"
}
