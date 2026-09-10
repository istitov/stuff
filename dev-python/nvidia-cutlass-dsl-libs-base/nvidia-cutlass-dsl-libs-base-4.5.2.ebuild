# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
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
	python_targets_python3_12? ( ${MY_BASE}/97/68/c1247ab848f26c4ab56e562eea0e3f31fc14c9aaf0d883afaa92d8f05592/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/0a/6e/bfe256ac08e5a6dfb11444809e54c76c3a2f05fff38dd173e2e71b95e4d2/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/3e/bc/5f9dd8c05c3e2f435228224f0b0e76e324c1bf0a6dcd3cfb917b5e94bad7/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA prohibits redistributing the binary payload.
RESTRICT="bindist mirror strip"

# Wheel-only binary subpackage required by nvidia-cutlass-dsl's base install.
# verified 2026-08-04
RDEPEND="
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/nvidia_cutlass_dsl/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

python_install() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die

	# The base and cu13 wheels overlap with differing content. Mirror pip's
	# cu13-overwrites-base result by retaining only base's unique LICENSE;
	# Portage would otherwise reject the collision. # verified 2026-08-04:
	# 1 unique, 180 shared
	local sp="${D}$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
	local nvdir="${sp}/nvidia_cutlass_dsl"
	local keep_re='^LICENSE$'
	local f rel
	while IFS= read -r -d '' f; do
		rel=${f#${nvdir}/}
		if [[ ! ${rel} =~ ${keep_re} ]]; then
			rm -f "${f}" || die "rm ${f} failed"
		fi
	done < <(find "${nvdir}" -type f -print0)
	find "${nvdir}" -type d -empty -delete
	# Let cu13 own its identical .pth that enables the cutlass import path.
	rm -f "${sp}/nvidia_cutlass_dsl.pth" || die
	python_optimize
}
