# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Example workflow templates for ComfyUI (meta-package)"
HOMEPAGE="
	https://github.com/Comfy-Org/workflow_templates
	https://pypi.org/project/comfyui-workflow-templates/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Upstream requires_dist pins each split to an exact version; ~ atoms track
# that == pin (any revision). Single-impl propagation via PYTHON_SINGLE_USEDEP.
RDEPEND="
	~dev-python/comfyui-workflow-templates-core-0.3.252[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-workflow-templates-media-api-0.3.80[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-workflow-templates-media-image-0.3.150[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-workflow-templates-media-other-0.3.217[${PYTHON_SINGLE_USEDEP}]
	~dev-python/comfyui-workflow-templates-media-video-0.3.91[${PYTHON_SINGLE_USEDEP}]
"
