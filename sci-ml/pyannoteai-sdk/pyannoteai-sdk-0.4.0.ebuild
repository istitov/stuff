# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Official Python SDK for the pyannoteAI hosted diarization API"
HOMEPAGE="
	https://github.com/pyannote/pyannoteAI-python-sdk
	https://pypi.org/project/pyannoteai-sdk/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/requests-2.32.3[${PYTHON_USEDEP}]
"
