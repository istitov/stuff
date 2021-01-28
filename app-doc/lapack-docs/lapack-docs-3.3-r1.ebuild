# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Documentation reference and man pages for LAPACK implementations"
HOMEPAGE="https://www.netlib.org/lapack/"
SRC_URI="https://dev.gentoo.org/~bicatali/lapack-man-${PV}.tar.gz
	https://www.netlib.org/lapack/lapackqref.ps"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE=""

S="${WORKDIR}/manpages"

src_install() {
	# These belong to the blas-docs
	rm -f man/manl/{csrot,lsame,xerbla,xerbla_array,zdrot}.*

	# rename because doman do not yet understand manl files
	# Not all systems have the rename command, like say FreeBSD
	local f t
	for f in man/manl/*.l; do
		t="${f%%.l}.n"
		mv "${f}" "${t}"
	done
	doman man/manl/*
	dodoc README "${DISTDIR}"/lapackqref.ps
}
