# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MODULE_AUTHOR=MEHNER
MODULE_VERSION=${PV}
inherit perl-module

DESCRIPTION="A dynamic Perl interface to gnuplot"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="
	dev-perl/Module-Build
	sci-visualization/gnuplot
"
DEPEND="${RDEPEND}"

SRC_TEST=do
