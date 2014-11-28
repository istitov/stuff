# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils python

DESCRIPTION="traGtor is a graphical user interface (GUI) for ffmpeg"
HOMEPAGE="http://mein-neues-blog.de/tragtor-gui-for-ffmpeg/"
SRC_URI="http://mein-neues-blog.de:9000/archive/${P}_all.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"

DEPEND=""
RDEPEND="dev-python/pygtk
	dev-python/dbus-python
	dev-python/pygobject
	media-video/ffmpeg
	media-sound/id3v2"

src_install() {
	dobin usr/bin/tragtor
	doicon usr/share/pixmaps/tragtor.svg
	domenu usr/share/applications/tragtor.desktop

	insinto /usr/share/tragtor
	doins usr/share/tragtor/*
}
