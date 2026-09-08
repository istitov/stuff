# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=2.35
inherit perl-module

DESCRIPTION="Allow subroutines in the PGPLOT graphics library to be called from Perl"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~x86"

RDEPEND="
	sci-libs/pgplot
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	${RDEPEND}
	>=dev-perl/Devel-CheckLib-1.140.0
	>=dev-perl/ExtUtils-F77-1.130.0
"

PATCHES=( "${FILESDIR}/${P}-ansi-prototypes.patch" )
