# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DIST_AUTHOR=KEICHNER
DIST_VERSION=${PV}
inherit perl-module

DESCRIPTION="Perl extension for displaying a progress indicator on a terminal"
LICENSE="|| ( Artistic GPL-2 )"

SLOT="0"
KEYWORDS="~amd64 ~x86"


SRC_TEST=do
