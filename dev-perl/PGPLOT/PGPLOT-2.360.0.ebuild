# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=2.36
inherit perl-module

DESCRIPTION="Allow subroutines in the PGPLOT graphics library to be called from Perl"

SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"

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

# 2.35 needed a -std=gnu89 workaround: pgfun.c forward-declared
# pgfun1/pgfun2/pgfunplot with empty (K&R) parens then called them with
# arguments, which gcc 16's default -std=gnu23 rejects. Upstream 2.36
# rewrote all three to ANSI prototypes (verified against the 2.35->2.36
# source diff: pgfun.c is the only C site and no K&R remains), so the
# flag is no longer needed. verified 2026-08-10 against 2.36.
