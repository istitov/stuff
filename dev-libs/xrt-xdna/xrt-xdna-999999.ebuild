# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit cmake python-any-r1 linux-info

DESCRIPTION="Runtime for AIE and FPGA based platforms"
HOMEPAGE="https://github.com/amd/xdna-driver"

if [[ ${PV} == 999999 ]] ; then
	EGIT_REPO_URI="https://github.com/amd/xdna-driver.git"
	# The VTD archives come from the vtd submodule, and XRT keeps nesting
	# further submodules; fetch all but the Windows-only Detours and the
	# kernel driver's libqdma, as dev-util/xrt-999999 does.
	EGIT_SUBMODULES=(
		'*'
		'-xrt/src/runtime_src/core/tools/xbtracer/Detours'
		'-xrt/src/runtime_src/core/pcie/driver/linux/xocl/lib/libqdma'
	)
	inherit git-r3
else
	VTD_HASH=c79b5d21568a4ffa5b0612a8279b352fc4e1109a

	declare -Ag submodules
	submodules["xrt"]=https://github.com/Xilinx/XRT.git@4eb1f4392a012b4e6eca759762389c612537f7c7
	submodules["xrt/src/runtime_src/aie-rt"]=https://github.com/Xilinx/aie-rt.git@a8b0667133ea2851ce27793a1796c5968226d9af
	submodules["xrt/src/runtime_src/core/common/aiebu"]=https://github.com/Xilinx/aiebu.git@9065273e0c0a4ac5930fff904ac245cf38dd3087
	submodules["xrt/src/runtime_src/core/common/elf"]=https://github.com/serge1/ELFIO.git@f849001fc229c2598f8557e0df22866af194ef98

	SRC_URI="
		https://github.com/amd/xdna-driver/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/Xilinx/VTD/raw/${VTD_HASH}/archive/strx/xrt_smi_strx.a -> xrt_smi_strx-${VTD_HASH:0:8}.a
		https://github.com/Xilinx/VTD/raw/${VTD_HASH}/archive/phx/xrt_smi_phx.a -> xrt_smi_phx-${VTD_HASH:0:8}.a
		https://github.com/Xilinx/VTD/raw/${VTD_HASH}/archive/npu3/xrt_smi_npu3.a -> xrt_smi_npu3-${VTD_HASH:0:8}.a
	"
	for k in "${!submodules[@]}"; do
		git_url="${submodules[$k]%@*}"
		commit_hash="${submodules[$k]#*@}"
		url_prefix="${git_url%.git}"
		SRC_URI+=" ${url_prefix}/archive/${commit_hash}.tar.gz -> ${url_prefix##*/}-${commit_hash:0:8}.tar.gz";
	done

	KEYWORDS="~amd64"
	S="${WORKDIR}/xdna-driver-${PV}"
fi

LICENSE="AMD-Binary-Only"
SLOT="0"

RESTRICT="bindist mirror strip"
[[ ${PV} == 999999 ]] && RESTRICT+=" network-sandbox"

RDEPEND="
	~dev-util/xrt-${PV}
	sys-apps/util-linux
"

DEPEND="
	sys-apps/util-linux
	dev-debug/systemtap
	dev-libs/boost
	dev-libs/opencl-icd-loader
	dev-libs/rapidjson
	dev-util/opencl-headers
	x11-libs/libdrm
"

BDEPEND+="
	${PYTHON_DEPS}
	$(python_gen_any_dep "
		dev-python/pybind11[\${PYTHON_USEDEP}]
	")
"

PATCHES=(
	"${FILESDIR}"/${PN}-999999-shim_err-c_str.patch
)

CONFIG_CHECK="~AMD_IOMMU ~DRM_ACCEL"

python_check_deps() {
	python_has_version -b "dev-python/pybind11[${PYTHON_USEDEP}]"
}

src_unpack() {
	if [[ ${PV} == 999999 ]] ; then
		git-r3_src_unpack
	else
		default

		pushd "${S}" || die
		for k in $(printf '%s\n' "${!submodules[@]}" | sort); do
			git_url="${submodules[$k]%@*}"
			commit_hash="${submodules[$k]#*@}"
			url_prefix="${git_url%.git}"
			rm -r "${k}" || die
			ln -s "${WORKDIR}/${url_prefix##*/}-${commit_hash}" "${k}" || die
		done

		local actual_vtd_hash=$(grep -oP 'VTD/raw/\K[0-9a-f]+' tools/info.json | head -n1)
		[[ "${actual_vtd_hash}" == "" ]] && die "Failed to extract VTD hash"
		[[ "${actual_vtd_hash}" != "${VTD_HASH}" ]] && \
			die "VTD hash mismatch, ebuild requested ${VTD_HASH} while package wants ${actual_vtd_hash}"

		mkdir -p amdxdna_bins/vtd_archives || die
		cp "${DISTDIR}/xrt_smi_strx-${VTD_HASH:0:8}.a" amdxdna_bins/vtd_archives/xrt_smi_strx.a || die
		cp "${DISTDIR}/xrt_smi_phx-${VTD_HASH:0:8}.a" amdxdna_bins/vtd_archives/xrt_smi_phx.a || die
		cp "${DISTDIR}/xrt_smi_npu3-${VTD_HASH:0:8}.a" amdxdna_bins/vtd_archives/xrt_smi_npu3.a || die
		popd || die
	fi
}

src_prepare() {
	grep -qF 'Unknown Linux package flavor' CMake/pkg.cmake ||
		die "package-flavor anchor moved"
	sed -e "/Unknown Linux package flavor/ s/FATAL_ERROR/MESSAGE/" -i "CMake/pkg.cmake" || die

	grep -qF 'set (XRT_UPSTREAM 0)' xrt/src/CMake/settings.cmake ||
		die "XRT_UPSTREAM anchor moved"
	sed -e "s/set (XRT_UPSTREAM 0)/set (XRT_UPSTREAM 1)/" -i xrt/src/CMake/settings.cmake || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}"/usr
		-DSKIP_KMOD=1
		-DUMQ_HELLO_TEST=n
		-DPython3_EXECUTABLE="${PYTHON}"
		-Wno-dev
	)
	[[ ${PV} != 999999 ]] && mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON )

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Upstream's CMake installs the VTD archives itself since they moved
	# into the vtd submodule; releases still carry them as distfiles.
	if [[ ${PV} != 999999 ]] ; then
		insinto /usr/share/xrt/amdxdna/bins
		doins amdxdna_bins/vtd_archives/*
	fi

	# Installed by dev-util/xrt.
	rm -rf "${ED}/bins" || die
}
