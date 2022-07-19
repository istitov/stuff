# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3

DESCRIPTION="A DeaDBeeF plugin for playing streaming video game music using vgmstream."
HOMEPAGE="https://github.com/johnwchadwick/deadbeef-vgmstream"
EGIT_REPO_URI="https://github.com/johnwchadwick/${PN}.git"

LICENSE="vgmstream"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
	media-libs/libvorbis
	media-sound/mpg123"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_prepare(){
	sed \
		-e "s|-I\$(DEADBEEF_ROOT)/include|-I/usr/include/deadbeef|" \
		-e "s|-I\$(DEADBEEF_ROOT)/lib|-I/usr/$(get_libdir)/deadbeef|" \
		-i Makefile || die "sed fail"
	default
}

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins vgm.so
}
