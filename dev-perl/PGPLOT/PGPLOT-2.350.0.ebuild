# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=2.35
inherit flag-o-matic perl-module

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

src_configure() {
	# pgfun.c forward-declares pgfun1/pgfun2/pgfunplot with empty parens
	# (K&R) then calls them with arguments. gcc 16's default (-std=gnu23)
	# treats `()` as `(void)` and rejects the calls with 'number of
	# arguments doesn't match prototype'. Pin to gnu89 so K&R survives.
	# verified 2026-05-10 against 2.35.
	append-cflags -std=gnu89

	perl-module_src_configure
}
