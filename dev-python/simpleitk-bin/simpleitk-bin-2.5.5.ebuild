# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
# Upstream ships a single cp311-abi3 wheel: the stable-ABI build loads on
# CPython 3.11 and every later release, so one wheel covers the whole
# PYTHON_COMPAT range. A source build would compile a bundled ITK
# (multi-hour, multi-GB); ::gentoo has no Insight Toolkit, hence -bin.
MY_WHEEL="${MY_PN}-${PV}-cp311-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"

DESCRIPTION="Simplified interface to the Insight Toolkit (ITK) for image analysis (binary)"
HOMEPAGE="
	https://simpleitk.org/
	https://github.com/SimpleITK/SimpleITK
	https://pypi.org/project/SimpleITK/
"
SRC_URI="https://files.pythonhosted.org/packages/9f/68/ed67a355a62848ee04bb4f01e89d3be871052c2c3ae6d5fc0fb2f6010979/${MY_WHEEL}"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="usr/lib/python3.*/site-packages/SimpleITK/*.so*"

src_unpack() {
	# distutils-r1 with DISTUTILS_USE_PEP517=no and a wheel SRC_URI would
	# try to unpack the .whl into S. Stash it and feed it to `installer`
	# per impl instead.
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	# One abi3 wheel installs into every enabled implementation;
	# distutils-r1 runs this phase per impl. python_optimize byte-compiles
	# all levels (installer alone misses the opt-2 .pyc).
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
	python_optimize
}
