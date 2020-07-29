# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MODULE_AUTHOR=DLAND
MODULE_VERSION=${PV}
inherit perl-module

DESCRIPTION="Assemble multiple Regular Expressions into a single RE"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=""
DEPEND=""
PATCHES=(
	"${FILESDIR}/${MODULE_VERSION}/no-pod-tests.patch"
)
SRC_TEST=do
