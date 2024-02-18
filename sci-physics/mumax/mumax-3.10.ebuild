# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit golang-build
EGO_PN="cmd/mumax3"
DESCRIPTION="GPU-accelerated micromagnetic simulator"
HOMEPAGE="http://mumax.github.io/"
SRC_URI="https://github.com/${PN}/3/archive/v${PV}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=dev-util/nvidia-cuda-toolkit-7.5.18-r2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/3-${PV}"
#EGO_PN="${S}/cmd/mumax3"
