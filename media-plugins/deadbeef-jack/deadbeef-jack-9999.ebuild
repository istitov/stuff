# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils git-r3

DESCRIPTION="JACK output plugin for DeaDBeeF."
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/jack"
EGIT_REPO_URI="https://gitorious.org/deadbeef-sm-plugins/jack.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND_COMMON="
	media-sound/deadbeef
	media-sound/jack-audio-connection-kit"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins jack.so
}
