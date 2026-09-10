# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN%-bin}
# One cp311-abi3 wheel supports every target. A source build compiles a bundled,
# multi-hour/multi-GB ITK unavailable in ::gentoo, hence -bin.
AMD64_WHEEL="${MY_PN}-${PV}-cp311-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
ARM64_WHEEL="${MY_PN}-${PV}-cp311-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"

case ${ARCH} in
	amd64) MY_WHEEL=${AMD64_WHEEL} ;;
	arm64) MY_WHEEL=${ARM64_WHEEL} ;;
esac

DESCRIPTION="Simplified interface to the Insight Toolkit (ITK) for image analysis (binary)"
HOMEPAGE="
	https://simpleitk.org/
	https://github.com/SimpleITK/SimpleITK
	https://pypi.org/project/simpleitk/
"
SRC_URI="
	amd64? ( https://files.pythonhosted.org/packages/9f/68/ed67a355a62848ee04bb4f01e89d3be871052c2c3ae6d5fc0fb2f6010979/${AMD64_WHEEL} )
	arm64? ( https://files.pythonhosted.org/packages/14/e5/6a77865140278c86a392a85bd2317a1097bd891f54955ebe5db623e4b37c/${ARM64_WHEEL} )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
	')
"

QA_PREBUILT="usr/lib/python3.*/site-packages/SimpleITK/*.so*"

src_unpack() {
	# Prevent default wheel unpacking; install it per implementation below.
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	# installer misses opt-2 bytecode; compile all levels explicitly.
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
	python_optimize
}
