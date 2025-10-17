# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3
DESCRIPTION="neat and simple webcam grabbing app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/
https://github.com/fsphil/fswebcam/"
EGIT_REPO_URI="https://github.com/fsphil/fswebcam.git"
LICENSE="GPL-2"
SLOT="0"

DEPEND="media-libs/gd"
RDEPEND="${DEPEND}"
