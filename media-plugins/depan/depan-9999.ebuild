# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 cmake-utils

DESCRIPTION="The DePanEstimate and DePan plugins, ported to avxsynth"
HOMEPAGE="https://github.com/btb/depan"
EGIT_REPO_URI="https://github.com/btb/depan.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sci-libs/fftw
	media-video/avxsynth"

RDEPEND=""
