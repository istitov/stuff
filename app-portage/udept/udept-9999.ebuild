# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/init-6/${PN}.git"
else
	SRC_URI="https://gitlab.com/init-6/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
fi

inherit bash-completion-r1

DESCRIPTION="A Portage analysis toolkit"
HOMEPAGE="https://gitlab.com/init-6/udept"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
#~amd64 ~mips ~ppc ~sparc ~x86
IUSE="bash-completion"

DEPEND="app-shells/bash:=
	sys-apps/portage"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

BASH_COMPLETION_NAME="dep"

src_configure() {
	econf $(use_enable bash-completion) || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog*
}
