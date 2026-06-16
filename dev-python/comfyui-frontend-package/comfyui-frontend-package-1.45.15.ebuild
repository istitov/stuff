# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Bundled web frontend assets for ComfyUI"
HOMEPAGE="
	https://github.com/Comfy-Org/ComfyUI_frontend
	https://pypi.org/project/comfyui-frontend-package/
"

# Upstream sdist ships no license metadata; the bundled static/ assets are
# the GPL-3.0 Comfy-Org/ComfyUI_frontend build. verified 2026-06-14
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

src_configure() {
	# setup.py derives the version from this env var, falling back to a bogus
	# 0.1.0; ComfyUI enforces a minimum frontend version at runtime, so the
	# real PV must reach the build. verified 2026-06-14
	export COMFYUI_FRONTEND_VERSION="${PV}"
	distutils-r1_src_configure
}
