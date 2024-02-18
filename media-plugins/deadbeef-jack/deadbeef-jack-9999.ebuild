# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="JACK output plugin for DeaDBeeF."
HOMEPAGE="https://github.com/tokiclover/deadbeef-plugins-jack"
EGIT_REPO_URI="https://github.com/tokiclover/deadbeef-plugins-jack"

LICENSE="MIT"
SLOT="0"

DEPEND_COMMON="
	media-sound/deadbeef
	media-sound/jack-audio-connection-kit"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins ddb_jack.so
}
