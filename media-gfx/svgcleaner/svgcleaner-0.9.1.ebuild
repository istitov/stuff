# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	bitflags@0.8.2
	clap@2.24.2
	float-cmp@0.2.3
	num-traits@0.1.39
	phf@0.7.21
	phf_shared@0.7.21
	simplecss@0.1.0
	siphasher@0.2.2
	svgdom@0.6.0
	svgparser@0.4.1
	unicode-segmentation@1.2.0
	unicode-width@0.1.4
	vec_map@0.8.0
"

inherit cargo

DESCRIPTION="SVG Cleaner cleans up your SVG files from unnecessary data."
HOMEPAGE="https://github.com/RazrFalcon/SVGCleaner"

SRC_URI="https://github.com/RazrFalcon/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
${CARGO_CRATE_URIS}"
KEYWORDS="~amd64 ~x86"

LICENSE="GPL-2"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

#QA_FLAGS_IGNORED="usr/bin/${PN}"

src_unpack() {
	unpack ${P}.tar.gz
	cargo_src_unpack
}
