# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A class library for C++ that manages integer overflows"
HOMEPAGE="https://github.com/dcleblanc/SafeInt"
SRC_URI="https://github.com/dcleblanc/SafeInt/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/SafeInt-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# 3.19+ is purely header-only — upstream dropped CMakeLists.txt,
# safe_math.{h,_impl.h}, and the build/install scaffolding the
# 3.0.28a ebuild had to patch in.  Just ship the header.

src_install() {
	doheader SafeInt.hpp
	einstalldocs
}
