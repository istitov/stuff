# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi xdg

DESCRIPTION="Small-angle scattering data analysis application"
HOMEPAGE="
	https://www.sasview.org/
	https://github.com/SasView/sasview
	https://pypi.org/project/sasview/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opencl"

RDEPEND="
	dev-python/bumps[${PYTHON_USEDEP}]
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/dominate[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/html2text[${PYTHON_USEDEP}]
	dev-python/html5lib[${PYTHON_USEDEP}]
	dev-python/ipython[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/mako[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/periodictable[${PYTHON_USEDEP}]
	dev-python/platformdirs[${PYTHON_USEDEP}]
	~dev-python/pyausaxs-1.0.4[${PYTHON_USEDEP}]
	dev-python/pybind11[${PYTHON_USEDEP}]
	dev-python/pylint[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/pyside[${PYTHON_USEDEP}]
	dev-python/pytools[${PYTHON_USEDEP}]
	dev-python/qtconsole[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/sasdata[${PYTHON_USEDEP}]
	dev-python/sasmodels[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/siphash24[${PYTHON_USEDEP}]
	dev-python/superqt[${PYTHON_USEDEP}]
	dev-python/tccbox[${PYTHON_USEDEP}]
	dev-python/twisted[${PYTHON_USEDEP}]
	dev-python/uncertainties[${PYTHON_USEDEP}]
	dev-python/zope-interface[${PYTHON_USEDEP}]
	opencl? ( dev-python/pyopencl[${PYTHON_USEDEP}] )
"
BDEPEND="
	dev-python/hatch-build-scripts[${PYTHON_USEDEP}]
	dev-python/hatch-requirements-txt[${PYTHON_USEDEP}]
	dev-python/hatch-sphinx[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
	dev-python/pyside[${PYTHON_USEDEP}]
"

# dev-python/xhtml2pdf is a soft upstream dep used for PDF report
# export; it cascades into a large pyHanko dep tree. Skipped here —
# SasView runs without it; only the PDF export feature breaks.
#
# Upstream pins pyausaxs==1.0.4; our pyausaxs is a stub triggering
# SasView's built-in fallback to its pure-Python scattering engine.

src_prepare() {
	# Drop all [[tool.hatch.build.targets.wheel.hooks.sphinx.tools]]
	# array-of-tables blocks. The range ends at the next regular table
	# header (`[foo]`, not `[[foo]]`) so consecutive sphinx entries are
	# handled correctly.
	sed -i \
		-e '/^\[\[tool\.hatch\.build\.targets\.wheel\.hooks\.sphinx/,/^\[[^[]/{/^\[[^[]/!d}' \
		pyproject.toml || die

	# Drop the force-include of a pre-built sas/docs/ tree; nothing
	# produces it in this build path.
	sed -i \
		-e '/^\[tool\.hatch\.build\.targets\.wheel\.force-include\]$/,/^\[/{/build\/doc\/html/d}' \
		pyproject.toml || die

	# xhtml2pdf and pywin32 intentionally dropped from build_tools/requirements.txt
	sed -i \
		-e '/^xhtml2pdf$/d' \
		-e '/^pywin32;/d' \
		build_tools/requirements.txt || die

	distutils-r1_src_prepare
}
