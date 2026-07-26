# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..15} )

# Upstream PyPI name ends in "-01" (a bundle/shard number); a Gentoo package
# name may not end in a hyphen followed by digits (PMS package-name syntax),
# so the package is named ...media-assets01 and PYPI_PN maps back to the real
# project for the sdist URL.
PYPI_PN="comfyui-workflow-templates-media-assets-01"

inherit distutils-r1 pypi

DESCRIPTION="Media assets bundle 01 for ComfyUI workflow templates (data)"
HOMEPAGE="
	https://github.com/Comfy-Org/workflow_templates
	https://pypi.org/project/comfyui-workflow-templates-media-assets-01/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
