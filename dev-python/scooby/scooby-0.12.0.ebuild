# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Lightweight tool to report Python package versions and system info"
HOMEPAGE="
	https://github.com/banesullivan/scooby
	https://pypi.org/project/scooby/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

# The sdist lacks git metadata; pin the version for setuptools-scm.
BDEPEND="
	>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	test? (
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		sys-process/time
	)
"

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

EPYTEST_PLUGINS=( pytest-console-scripts )
distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# require unpackaged no-version
	tests/test_scooby.py::test_get_version
	tests/test_scooby.py::test_tracking
	# requires pyvips to be installed without its runtime library
	tests/test_scooby.py::test_import_os_error
)
