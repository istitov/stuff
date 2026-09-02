# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the openai API"
HOMEPAGE="
	https://github.com/openai/openai-python
	https://pypi.org/project/openai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# 3.6.0 dropped the distro dependency: _base_client.py now reads
# platform.freedesktop_os_release() from the stdlib instead (verified in the
# 3.6.0 sdist -- no `import distro` remains). The pydantic floor also rose
# 1.9.0 -> 1.10.13; upstream additionally excludes pydantic 2.0.*-2.3.*, which
# is unreachable here since ::gentoo's oldest pydantic is 2.13.4 -- so only
# the `<3` half of that constraint is transcribed.
# Upstream's other major ceilings are carried too: without them a future
# ::gentoo bump to jiter 1.x, anyio 5.x or typing-extensions 5.x would be
# silently accepted. sniffio is deliberately left unbounded -- openai declares
# it bare, unlike anthropic which pins <2.
# verified 2026-08-29 against the 3.6.0 sdist PKG-INFO.
RDEPEND="
	>=dev-python/anyio-4.10.0[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.7.0[${PYTHON_USEDEP}]
	<dev-python/httpx2-3[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.16.0[${PYTHON_USEDEP}]
	<dev-python/jiter-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10.13[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
"
# No hatch-fancy-pypi-readme: 3.6.0's build-system is bare
# requires = ["hatchling==1.27.0"] with no [tool.hatch.metadata.hooks.fancy-pypi-readme]
# section. 3.5.0 and earlier did use it, so the dep was carried forward stale
# by the copy. (anthropic still needs it -- its build-system keeps
# hatch-fancy-pypi-readme>=22.4,<26 and the hook.) verified 2026-08-29 against
# the 3.6.0 sdist pyproject.toml.

# Tests need the same Stainless mock-server stack as anthropic.
RESTRICT="test"
