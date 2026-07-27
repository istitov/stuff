# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library to write tables in various text/binary formats"
HOMEPAGE="
	https://github.com/thombashi/pytablewriter
	https://pypi.org/project/pytablewriter/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# Two upstream requirements are deliberately not mirrored here.
#
# "typepy[datetime]<2,>=1.3.2": the cap is stale rather than real. 1.2.1 was
# released 2025-01-01, sixteen months before typepy 2.0.0 existed, so it is a
# pre-emptive major-version guard, not a known break. typepy 2.0.0's only
# breaking change is swapping pytz for zoneinfo, and the author's sibling
# packages that we also ship - dataproperty and tabledata - already allow <3.
# Checked directly: MarkdownTableWriter renders a table with tz-aware
# datetimes against typepy-2.0.0. verified 2026-07-27
#
# "setuptools>=38.3.0": upstream lists it as a runtime requirement, but the
# installed tree contains no import of setuptools or pkg_resources anywhere,
# so it is spurious. verified 2026-07-27
RDEPEND="
	dev-python/dataproperty[${PYTHON_USEDEP}]
	dev-python/mbstrdecoder[${PYTHON_USEDEP}]
	dev-python/pathvalidate[${PYTHON_USEDEP}]
	dev-python/tabledata[${PYTHON_USEDEP}]
	dev-python/tcolorpy[${PYTHON_USEDEP}]
	dev-python/typepy[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
