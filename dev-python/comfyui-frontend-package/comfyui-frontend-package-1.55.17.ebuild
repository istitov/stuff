# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Bundled web frontend assets for ComfyUI"
HOMEPAGE="
	https://github.com/Comfy-Org/ComfyUI_frontend
	https://pypi.org/project/comfyui-frontend-package/
"

# The sdist lacks license metadata; its bundled frontend assets are GPL-3.
# Verified 2026-06-14.
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_configure() {
	# setup.py defaults to 0.1.0; ComfyUI checks the frontend version at runtime.
	export COMFYUI_FRONTEND_VERSION="${PV}"
	distutils-r1_src_configure
}
