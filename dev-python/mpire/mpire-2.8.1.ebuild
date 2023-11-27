# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="A Python package for easy multiprocessing"
HOMEPAGE="https://github.com/sybrenjansen/mpire"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc python"

RDEPEND="
	dev-python/pygments[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/multiprocess[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
"
#            'docs': ['docutils==0.17.1',
#                     'sphinx==3.2.1',
#                     'sphinx-rtd-theme==0.5.0',
#                     'sphinx-autodoc-typehints==1.11.0',
#                     'sphinxcontrib-images==0.9.2',
#                     'sphinx-versions==1.0.1'],
#            'testing': ['dataclasses; python_version<"3.7"',
#                        'multiprocess; python_version<"3.11"',
#                        'multiprocess>=0.70.15; python_version>="3.11"',
#                        'numpy',
#

##!!!dashboard to be configured; setuptools issue

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
