# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="A simple stereo widener plugin for DeaDBeeF."
HOMEPAGE="https://github.com/DeaDBeeF-Player/stereo-widener"
EGIT_REPO_URI="https://github.com/DeaDBeeF-Player/stereo-widener"

LICENSE="MIT"
SLOT="0"

DEPEND_COMMON="media-sound/deadbeef"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_install(){
	insinto /usr/$(get_libdir)/deadbeef
	doins stereo_widener.so
}
