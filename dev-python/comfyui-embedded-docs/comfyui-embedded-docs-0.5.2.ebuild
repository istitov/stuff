# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Embedded per-node documentation assets for ComfyUI"
HOMEPAGE="
	https://github.com/Comfy-Org/embedded-docs
	https://pypi.org/project/comfyui-embedded-docs/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
