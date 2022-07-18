# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=ANDYA
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Monitor files and directories for changes"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="
	dev-perl/Module-Build
"

DEPEND="${RDEPEND}"

SRC_TEST=do
