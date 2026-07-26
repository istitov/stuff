# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/istitov/${PN}.git"
else
	SRC_URI="https://github.com/istitov/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
fi

DESCRIPTION="A Portage analysis toolkit"
HOMEPAGE="https://github.com/istitov/udept"

LICENSE="GPL-3"
SLOT="0"
# Retained for rollback only, and masked in profiles/package.mask. An
# empty KEYWORDS keeps it out of every arch's default resolution while
# leaving it installable via ACCEPT_KEYWORDS="**".
KEYWORDS=""
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
