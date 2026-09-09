# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
ROCM_SKIP_GLOBALS=1
inherit cmake linux-info python-r1 rocm

# Match upstream's immutable ESMI_GIT_HASH; the 4.2 tag used for ROCm 7.2 lacks
# ROCm 10 APIs. Recheck CMakeLists.txt each bump. verified 2026-08-30
ESMI_COMMIT="d494a3194ceb4cc4dbb2debf9fcbe8773c6d3bef"

DESCRIPTION="AMD System Management Interface for managing and monitoring GPUs"
HOMEPAGE="
	https://github.com/ROCm/rocm-systems/tree/develop/projects/amdsmi
	https://rocm.docs.amd.com/projects/amdsmi/en/latest/
"
# Gentoo stops at ROCm 7.2; rebuilding it would downgrade rocm-core and conflict
# with the ROCm 10 stack. ROCm 10 ships amdsmi only from the rocm-systems
# therock-X.Y asset; fetch separately versioned ESMI at upstream's commit.
# verified 2026-08-30
SRC_URI="
	https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz
		-> ${P}.tar.gz
	https://github.com/amd/esmi_ib_library/archive/${ESMI_COMMIT}.tar.gz
		-> esmi_ib_library-${ESMI_COMMIT}.tar.gz
"
S="${WORKDIR}/${PN}"
ESMI_S="${WORKDIR}/esmi_ib_library-${ESMI_COMMIT}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	test? ( dev-cpp/gtest )
	x11-libs/libdrm[video_cards_amdgpu]
	dev-libs/rocm-core:${SLOT}
"
RDEPEND="
	${PYTHON_DEPS}
"

CONFIG_CHECK="~HSA_AMD ~DRM_AMDGPU"

src_prepare() {
	# Presence of src/e_smi.c suppresses upstream's network FetchContent path.
	ln -s "${ESMI_S}" esmi_ib_library || die

	# Guard sed anchors because a no-match succeeds silently. verified 2026-08-30
	local f

	# Raise obsolete CMake 3.5 floors.
	for f in goamdsmi_shim/CMakeLists.txt "${ESMI_S}"/CMakeLists.txt; do
		grep -q 'cmake_minimum_required' "${f}" ||
			die "cmake_minimum_required anchor moved in ${f}"
	done
	sed -e "/cmake_minimum_required/ s/3\.5\.0/3.10/" \
		-i goamdsmi_shim/CMakeLists.txt "${ESMI_S}"/CMakeLists.txt || die

	for f in CMakeLists.txt "${ESMI_S}"/CMakeLists.txt goamdsmi_shim/CMakeLists.txt; do
		grep -q -- '-Wall -Wextra' "${f}" ||
			die "-Wall -Wextra anchor moved in ${f}"
	done
	sed -e "s/-Wall -Wextra//" \
		-i CMakeLists.txt "${ESMI_S}"/CMakeLists.txt goamdsmi_shim/CMakeLists.txt || die

	# Prevent installation under a private ROCm prefix.
	grep -q 'generic_add_rocm' CMakeLists.txt ||
		die "generic_add_rocm anchor moved; the custom ROCm install path would not be reset"
	sed -e "/generic_add_rocm/d" -i CMakeLists.txt || die

	# shellcheck disable=SC2016
	grep -q 'doc/${CPACK_PACKAGE_NAME}' CMakeLists.txt ||
		die "docdir anchor moved; docs would install under CPACK_PACKAGE_NAME"
	sed -e "s:doc/\${CPACK_PACKAGE_NAME}:doc/${P}:" -i CMakeLists.txt || die

	grep -q 'COMPONENT asan' CMakeLists.txt ||
		die "COMPONENT asan anchor moved; the asan component would be installed"
	sed -e "s/COMPONENT asan/COMPONENT asan EXCLUDE_FROM_ALL/" -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	python_setup

	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-Wno-dev
	)
	use test && mycmakeargs+=( -DCMAKE_REQUIRE_FIND_PACKAGE_GTest=ON )
	cmake_src_configure
}

src_test() {
	# Read-only system/ID tests access the render node.
	addwrite /dev/dri/renderD128

	# ASUS GZ302E exposes no kernel metrics for these reads.
	GTEST_FILTER="-amdsmitstReadOnly.TempRead:amdsmitstReadOnly.TestFrequenciesRead" \
	"${BUILD_DIR}/tests/amd_smi_test/amdsmitst" || die "Test failed"
}

src_install() {
	cmake_src_install

	rm "${ED}"/usr/share/amd_smi/amdsmi/{libamd_smi.so,LICENSE,README.md} || die

	python_fix_shebang "${ED}"/usr/libexec/amdsmi_cli
	python_domodule "${ED}"/usr/libexec/amdsmi_cli
	python_domodule "${ED}"/usr/share/amd_smi/amdsmi

	fperms a+x "/usr/lib/${EPYTHON}/site-packages/amdsmi_cli/amdsmi_cli.py"
	dosym -r "/usr/lib/${EPYTHON}/site-packages/amdsmi_cli/amdsmi_cli.py" /usr/bin/amd-smi

	rm -rf "${ED}"/usr/share/amd_smi "${ED}"/usr/libexec/amdsmi_cli || die
}
