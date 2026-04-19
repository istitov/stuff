# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="GPU-accelerated micromagnetic simulator"
HOMEPAGE="http://mumax.github.io/"
SRC_URI="https://github.com/${PN}/3/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/3-${PV}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=dev-util/nvidia-cuda-toolkit-7.5.18-r2"
RDEPEND="${DEPEND}"

src_compile() {
	ego build -o mumax3 ./cmd/mumax3
}

src_install() {
	dobin mumax3
	einstalldocs
}
