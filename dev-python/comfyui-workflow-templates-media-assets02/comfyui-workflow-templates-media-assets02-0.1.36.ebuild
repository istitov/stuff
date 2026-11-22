# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..15} )

# PMS forbids names ending in -<digits>; map assets02 to upstream's assets-02.
PYPI_PN="comfyui-workflow-templates-media-assets-02"

inherit distutils-r1 pypi

DESCRIPTION="Media assets bundle 02 for ComfyUI workflow templates (data)"
HOMEPAGE="
	https://github.com/Comfy-Org/workflow_templates
	https://pypi.org/project/comfyui-workflow-templates-media-assets-02/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="$(python_gen_cond_dep '
	>=dev-python/setuptools-61[${PYTHON_USEDEP}]
')"
