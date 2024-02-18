# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DESCRIPTION="SVG Cleaner cleans up your SVG files from unnecessary data."
HOMEPAGE="https://github.com/RazrFalcon/SVGCleaner"
EGIT_REPO_URI="https://github.com/RazrFalcon/SVGCleaner.git"

if [[ ${PV} == *9999* ]]; then
	inherit cargo git-r3
	EGIT_REPO_URI="https://github.com/RazrFalcon/${PN}.git"
	EGIT_BRANCH="master"
else
	inherit cargo
	SRC_URI="https://github.com/RazrFalcon/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"

DEPEND="
	virtual/rust
	dev-lang/rust
"
#dev-util/cargo#cargo (the program) being moved into dev-lang/rust,
RDEPEND="${DEPEND}"

src_compile() {
	cargo build --release
}
src_install() {
	cargo_src_install
}
