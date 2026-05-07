# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="A Portage analysis toolkit, written in bash"
HOMEPAGE="https://github.com/istitov/udept"
SRC_URI="https://github.com/istitov/udept/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+bash-completion"

RDEPEND="
	>=app-shells/bash-4.2:0
	>=sys-apps/portage-2.3.0
	bash-completion? ( app-shells/bash-completion )
"
BDEPEND=">=app-shells/bash-4.2:0"

DOCS=( ChangeLog README.md )

src_configure() {
	econf $(use_enable bash-completion)
}
