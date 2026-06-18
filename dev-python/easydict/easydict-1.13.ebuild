# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Access dict values as attributes (recursively)"
HOMEPAGE="
	https://github.com/makinacorpus/easydict
	https://pypi.org/project/easydict/
"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
