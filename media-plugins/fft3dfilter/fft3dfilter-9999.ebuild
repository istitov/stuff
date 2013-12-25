# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/fft3dfilter/fft3dfilter-9999.ebuild,v 1.1 2013/12/24 18:11:23 brothermechanic Exp $

EAPI=5

inherit git-2 eutils

DESCRIPTION="FFT3DFilter hacked to work on linux"
HOMEPAGE="https://github.com/fundies/fft3dfilter-linux"
EGIT_REPO_URI="https://github.com/fundies/fft3dfilter-linux.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sci-libs/fftw
		media-video/avxsynth"

RDEPEND=""

S="${WORKDIR}/fft3dfilter-linux"

src_install() {
	insinto /usr/lib/avxsynth/
	doins fft3dfilter.so
}
