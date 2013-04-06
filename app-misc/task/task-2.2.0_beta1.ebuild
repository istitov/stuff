# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/task/task-2.1.2.ebuild,v 1.3 2012/10/04 22:33:32 radhermit Exp $

EAPI=4

inherit versionator eutils cmake-utils bash-completion-r1

DESCRIPTION="Taskwarrior is a command-line todo list manager"
HOMEPAGE="http://taskwarrior.org/projects/show/taskwarrior/"
MY_PV=$(replace_version_separator 3 '.' )
SRC_URI="http://taskwarrior.org/download/${PN}-${MY_PV}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="lua vim-syntax zsh-completion"

DEPEND="lua? ( dev-lang/lua )"
RDEPEND="${DEPEND}"

src_prepare() {
	# Use the correct directory locations
	sed -i -e "s:/usr/local/share/doc/task/rc:/usr/share/task/rc:" \
		doc/man/taskrc.5.in doc/man/task-tutorial.5.in doc/man/task-color.5.in || die
	sed -i -e "s:/usr/local/bin:/usr/bin:" doc/man/task-faq.5.in scripts/add-ons/* || die

	# Don't automatically install scripts
	sed -i -e '/scripts/d' CMakeLists.txt || die

	epatch "${FILESDIR}"/${PN}-2.0.0_beta4-rcdir.patch
}

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_enable lua LUA)
		-DTASK_DOCDIR=/usr/share/doc/${PF}
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newbashcomp scripts/bash/task.sh task

	if use lua ; then
		insinto /usr/share/${PN}/extensions
		doins scripts/extensions/*
	fi

	if use vim-syntax ; then
		rm scripts/vim/README
		insinto /usr/share/vim/vimfiles
		doins -r scripts/vim/*
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins scripts/zsh/*
	fi

	exeinto /usr/share/${PN}/scripts
	doexe scripts/add-ons/*
}
