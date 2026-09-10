# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
# Match PyQt5's supported implementations for reverse dependencies.
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="sip extension module for PyQt5"
HOMEPAGE="https://pypi.org/project/PyQt5-sip/"

LICENSE="BSD-2"
SLOT="0/$(ver_cut 1)"
KEYWORDS="amd64 arm arm64 ~loong ~ppc ppc64 ~riscv x86"
