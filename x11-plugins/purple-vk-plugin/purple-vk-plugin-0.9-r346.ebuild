# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit cmake-utils

DESCRIPTION="Pidgin plugin for vk.com social network"
HOMEPAGE="https://bitbucket.org/olegoandreev/purple-vk-plugin"
SRC_URI="https://bitbucket.org/olegoandreev/purple-vk-plugin/downloads/purple-vk-plugin-0.9+r346.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="net-im/pidgin[ncurses]
	>=dev-libs/libxml2-2.7
	sys-devel/gettext"

S="${WORKDIR}/purple-vk-plugin-0.9+r346"
