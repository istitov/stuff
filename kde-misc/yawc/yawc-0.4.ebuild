# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VIRTUALX_REQUIRED="test"
inherit kde4-base

DESCRIPTION="Yet Another Window Control - KWinButton applet analog"
HOMEPAGE="http://kde-apps.org/content/show.php/Yet+Another+Window+Control?content=139916"
SRC_URI="http://kde-apps.org/CONTENT/content-files/139916-${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug test"

DEPEND="kde-base/libkworkspace:4
		kde-base/libtaskmanager:4"
RDEPEND="${DEPEND}"
