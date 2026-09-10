# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUTLASS Python DSL — base shared libs"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-base/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/09/df/e606ae9ea51b2dc7e8942177d9487cfb718ef819769cfe641588c976641b/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/f7/1d/e19ae692f4ed485f5026834801cd044007be6a11bd30f3dad407c1422fe5/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/c8/b5/6cf58671e7d9a9163da5fab2b171e3d30446df008635a1206ea4aca3d487/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA prohibits redistributing the binary payload.
RESTRICT="bindist mirror strip"

# Binary-only split wheel. iket is its sole protobuf consumer and works with
# 7.35.1, so omit upstream's <7 cap. verified 2026-08-04
RDEPEND="
	~dev-python/nvidia-cutlass-dsl-libs-core-${PV}[${PYTHON_USEDEP}]
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/protobuf-6.30.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/nvidia_cutlass_dsl/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

# Since 4.6.0, base and cu13 payloads are disjoint; no collision dedup is
# needed. The parent wheel's .pth enables `import cutlass`. verified 2026-08-04
python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die
	python_optimize
}
