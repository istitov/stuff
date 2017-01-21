# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 kde4-base

DESCRIPTION="KDE4 plasmoid. Removes the \"hand\" in upper right corner of the screen"
HOMEPAGE="https://github.com/gustavosbarreto/plasma-ihatethecashew"
EGIT_REPO_URI="https://github.com/gustavosbarreto/plasma-ihatethecashew.git"

LICENSE="GPL-3"
KEYWORDS=""
SLOT="0"
IUSE="debug"

RDEPEND="
	$(add_kdebase_dep plasma-workspace)
"
