# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit autotools git-r3

DESCRIPTION="A Portage analysis toolkit, written in bash"
HOMEPAGE="https://github.com/istitov/udept"
EGIT_REPO_URI="https://github.com/istitov/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
IUSE="+bash-completion +zsh-completion test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-shells/bash-4.2:0
	>=sys-apps/portage-2.3.0
	bash-completion? ( app-shells/bash-completion )
"
BDEPEND="
	>=app-shells/bash-4.2:0
	test? (
		dev-util/bats
		dev-util/bats-support
		dev-util/bats-assert
	)
"

DOCS=( ChangeLog README.md )

src_prepare() {
	default
	# Live tree doesn't ship the release-tarball-generated autotools
	# bootstrap (configure, Makefile.in, COPYING via automake --add-missing).
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable bash-completion) \
		$(use_enable zsh-completion)
}
