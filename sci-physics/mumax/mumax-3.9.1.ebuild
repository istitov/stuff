# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit golang-build
EGO_PN="cmd/mumax3"
DESCRIPTION="GPU-accelerated micromagnetic simulator"
HOMEPAGE="http://mumax.github.io/"
SRC_URI="https://github.com/${PN}/3/archive/v${PV}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-util/nvidia-cuda-toolkit"
RDEPEND="${DEPEND}"

S="${WORKDIR}/3-${PV}"
#EGO_PN="${S}/cmd/mumax3"
