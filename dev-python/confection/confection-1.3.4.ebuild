# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The sweetest config system for Python"
HOMEPAGE="
	https://github.com/explosion/confection
	https://pypi.org/project/confection/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# This release implements validation and serialization internally. Its only
# conditional dependency is typing-extensions on Python <3.11, outside our
# targets. pydantic is imported only if present, to recognise BaseModel
# schemas, and srsly is not imported at all. verified 2026-10-27
