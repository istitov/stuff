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
	python_targets_python3_12? ( ${MY_BASE}/d6/ba/f8c3f7db3de25be75e13527cd88a3019f0036370c9769ceefd1cf8165c76/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/2a/bf/b33e5cecde6ea3cecbb604b8dee8d8b0c07a42c886f2929a709fdcd86f8b/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/f0/47/aab054ab9f2400f803233d1506019f4e5d93ef9c30e8000fc62902a516cb/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
# NVIDIA-CUDA is an EULA license; distfiles must not be mirrored,
# binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# Wheel-only on PyPI (binary CUDA-shared bits with no source release).
# Sub-package of the nvidia-cutlass-dsl umbrella; required by the
# parent's base install. # verified 2026-05-07 against 4.5.0.
RDEPEND="
	dev-python/cuda-python[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/cutlass/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die

	# This wheel and the sibling nvidia-cutlass-dsl-libs-cu13 wheel
	# overlap on 217 file paths but ship subtly different *contents*
	# at those paths (CUDA-13 builds vs the base build). pip's
	# behaviour when both are installed is "cu13 overwrites base";
	# Portage's collision-protect would error instead. We mirror
	# pip's end state here by keeping only this wheel's *unique*
	# files (LICENSE, libcuda_dialect_runtime_static.a, utils/block.py)
	# — three files in 4.5.0, verified against the cu13 wheel's
	# manifest. The cu13 ebuild then installs everything else,
	# including its own variants of the shared paths.
	# # verified 2026-05-07 against 4.5.0.
	local sp="${D}$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
	local nvdir="${sp}/nvidia_cutlass_dsl"
	local keep_re='^(LICENSE|lib/libcuda_dialect_runtime_static\.a|python_packages/cutlass/utils/block\.py)$'
	local f rel
	while IFS= read -r -d '' f; do
		rel=${f#${nvdir}/}
		if [[ ! ${rel} =~ ${keep_re} ]]; then
			rm -f "${f}" || die "rm ${f} failed"
		fi
	done < <(find "${nvdir}" -type f -print0)
	# Drop any now-empty subdirs.
	find "${nvdir}" -type d -empty -delete
	# .pth is a top-level sibling of the package dir and the cu13
	# wheel ships an identical one — let cu13 own it. (The .pth
	# enables nvidia_cutlass_dsl/python_packages/ as an extra import
	# path, which is what makes `import cutlass` work.)
	rm -f "${sp}/nvidia_cutlass_dsl.pth" || die
}
