# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=DLAND
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Assemble multiple Regular Expressions into a single RE"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=""
DEPEND=""
#PATCHES=(
#	"${FILESDIR}/${PV}/no-pod-tests.patch"
#)
SRC_TEST=do
