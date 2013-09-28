# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils cmake-utils bash-completion-r1

DESCRIPTION="Taskwarrior is a command-line todo list manager"
HOMEPAGE="http://taskwarrior.org/projects/show/taskwarrior/"
MY_P="${PN}-${PV/_/.}"
SRC_URI="http://taskwarrior.org/download/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x64-macos ~arm"
IUSE="vim-syntax zsh-completion"
S="${WORKDIR}/${MY_P}"

src_prepare() {
	# don't automatically install scripts
	sed -i -e '/scripts/d' CMakeLists.txt || die
}

src_configure() {
	mycmakeargs=(
		-DTASK_DOCDIR="${EPREFIX}"/usr/share/doc/${PF}
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	exeinto /usr/share/${PN}/scripts
	doexe scripts/*
}
