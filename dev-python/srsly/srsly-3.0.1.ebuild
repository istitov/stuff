# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Modern high-performance serialization utilities for Python"
HOMEPAGE="
	https://github.com/explosion/srsly
	https://pypi.org/project/srsly/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

# 3.0 unvendors cloudpickle, ruamel.yaml and ujson and is pure Python;
# spaCy and Thinc still cap srsly below 3.
# Upstream caps ujson <6 (explosion/srsly#120, March 2026). The PR sets
# "sane but reasonable version pins" before ujson 6 existed, not a known
# break, and ::gentoo has only ujson 6. srsly calls only ujson.dumps
# (indent, escape_forward_slashes), loads and load; its whole test suite,
# the JSON tests included, passed against ujson 6.1.0. verified 2026-11-05
RDEPEND="
	>=dev-python/cloudpickle-3.1.2[${PYTHON_USEDEP}]
	<dev-python/cloudpickle-4[${PYTHON_USEDEP}]
	>=dev-python/msgpack-1.1[${PYTHON_USEDEP}]
	<dev-python/msgpack-2[${PYTHON_USEDEP}]
	>=dev-python/ruamel-yaml-0.18.16[${PYTHON_USEDEP}]
	<dev-python/ruamel-yaml-1[${PYTHON_USEDEP}]
	>=dev-python/ujson-5.11.0[${PYTHON_USEDEP}]
	<dev-python/ujson-7[${PYTHON_USEDEP}]
"
BDEPEND="
	test? ( dev-python/numpy[${PYTHON_USEDEP}] )
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	grep -qF 'ujson >=5.11.0,<6' setup.cfg || die "ujson cap anchor moved"
	sed -i -e 's/ujson >=5.11.0,<6/ujson >=5.11.0,<7/' setup.cfg || die
}
