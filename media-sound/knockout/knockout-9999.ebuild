# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit git-2

DESCRIPTION="Port of kn0ck0ut to LV2 plugin"
HOMEPAGE="https://github.com/jeremysalwen/kn0ck0ut-lv2"
EGIT_REPO_URI="https://github.com/jeremysalwen/kn0ck0ut-LV2.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND="
	  media-libs/lv2
	  dev-util/lv2-c++-tools
	  sci-libs/fftw"
DEPEND="${RDEPEND}"
