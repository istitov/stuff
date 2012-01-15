# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils subversion

DESCRIPTION="High perfomance C++ library"
HOMEPAGE="http://libcxx.llvm.org/"
ESVN_REPO_URI="http://llvm.org/svn/llvm-project/libcxx/trunk"
KEYWORDS="~amd64"
IUSE=""

SLOT=0

DEPEND="sys-devel/clang"

CXX="clang++"
CC="clang"