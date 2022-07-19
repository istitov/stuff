# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3

DESCRIPTION="DeaDBeeF filebrowser plugin "
HOMEPAGE="https://sourceforge.net/projects/deadbeef-fb/"
EGIT_REPO_URI="https://git.code.sf.net/p/deadbeef-fb/code"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

#S="${WORKDIR}/deadbeef-devel"

src_configure() {
	sed -i "s/errno/errorNum/g" utils.c
	sed -i "s/gtk_css_provider_get_default/gtk_css_provider_new/g" utils.c
	./autogen.sh
	my_config="--disable-static
	  --enable-gtk3
	  --disable-gtk2
	"
	econf ${my_config}
}

src_install() {
	emake DESTDIR="${D}" install
	find "${D}" -name "${PN}-${PV}" -exec rm -rf {} +
}
#Not compiling
