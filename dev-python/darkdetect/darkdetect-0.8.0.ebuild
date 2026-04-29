# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Detect OS Dark Mode from Python"
HOMEPAGE="
	https://github.com/albertosottile/darkdetect
	https://pypi.org/project/darkdetect/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# No runtime deps on Linux — upstream's only requires_dist is
# pyobjc-framework-Cocoa, gated by `extra == 'macos-listener'` and
# `platform_system == "Darwin"`.
