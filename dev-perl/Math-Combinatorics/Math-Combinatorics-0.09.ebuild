# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DIST_AUTHOR=ALLENDAY
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Perform combinations and permutations on lists"
LICENSE="|| ( Artistic GPL-2 )"

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""
DEPEND=""

SRC_TEST=do
