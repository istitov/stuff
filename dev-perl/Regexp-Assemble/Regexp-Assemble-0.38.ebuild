# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=RSAVAGE
DIST_VERSION=${PV}
DIST_A_EXT=tgz
inherit perl-module

DESCRIPTION="Assemble multiple Regular Expressions into a single RE"

SLOT="0"
KEYWORDS="~amd64 ~x86"
#PATCHES=(
#	"${FILESDIR}/${PV}/no-pod-tests.patch"
#)
SRC_TEST=do
