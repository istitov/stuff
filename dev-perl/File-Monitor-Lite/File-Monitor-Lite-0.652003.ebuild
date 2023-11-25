# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=DRYMAN
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Monitor file changes"

SLOT="0"
KEYWORDS="~amd64 ~x86"

SRC_TEST=do
