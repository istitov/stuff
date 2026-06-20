# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=BDFOY
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Perl extension for working with Chemical Elements"

SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

SRC_TEST=do
