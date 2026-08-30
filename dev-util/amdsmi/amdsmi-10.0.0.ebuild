# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
ROCM_SKIP_GLOBALS=1
inherit cmake linux-info python-r1 rocm

# esmi_ib_library is vendored by commit, not by tag: upstream's CMakeLists.txt
# sets ESMI_GIT_HASH to this exact hash and fetches it with FetchContent
# ("Pin to an immutable commit hash so the sources can't be swapped by a moved
# tag"). Take the same pin -- ::gentoo's 7.2.0 ebuild used the esmi_pkg_ver-4.2
# TAG, which is too old for the 10.0 API and fails to compile with e.g.
# "too many arguments to function esmi_pwr_efficiency_mode_set" plus a batch of
# undeclared esmi_{pc6,cc6}_enable_* / esmi_xgmi_pstate_range_get symbols.
# Re-read this hash from upstream's CMakeLists.txt on every bump.
# verified 2026-08-30.
ESMI_COMMIT="d494a3194ceb4cc4dbb2debf9fcbe8773c6d3bef"

DESCRIPTION="AMD System Management Interface for managing and monitoring GPUs"
HOMEPAGE="
	https://github.com/ROCm/rocm-systems/tree/develop/projects/amdsmi
	https://rocm.docs.amd.com/projects/amdsmi/en/latest/
"
# Forked into ::stuff for ROCm 10.0. ::gentoo stops at 7.2.x, and amdsmi
# build-depends on dev-libs/rocm-core:${SLOT} -- so with rocm-core-10.0.0
# installed the ::gentoo ebuild cannot be rebuilt at all: portage answers a
# rebuild request by trying to DOWNGRADE rocm-core to 7.2.4, which collides
# with dev-util/hip-10.0.0's ~dev-libs/rocm-core-10.0.0. An installed
# amdsmi-7.2.0 keeps working (its RDEPEND is python-only), so this is invisible
# until something triggers a rebuild -- `emerge -uDN @world` does, which is how
# it surfaced. verified 2026-08-30.
#
# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28) and ROCm/amdsmi
# stops cutting its own tags at therock-7.10; the 10.0 source ships only as the
# amdsmi.tar.gz asset on the rocm-systems therock-<major.minor> release, the
# same shape dev-util/roctracer and dev-libs/rocm-core already use.
#
# esmi_ib_library is not part of the ROCm release train and is versioned
# independently, so it is fetched separately -- but by the commit hash upstream
# pins rather than by tag; see ESMI_COMMIT above for why the tag ::gentoo used
# does not work here.
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

# ::gentoo's 7.2.0 ebuild carries two patches. BOTH are upstreamed at 10.0 and
# are deliberately not forked in; verified 2026-08-30 against the pristine
# therock-10.0 tarball:
#
#   amdsmi-7.0.2-no-git.patch -- stopped CMake cloning/updating esmi_ib_library
#   at configure time, which cannot work under network-sandbox. Upstream
#   rewrote the whole block: the fetch now sits behind
#   `if(NOT EXISTS "${ESMI_SOURCE_DIR}/src/e_smi.c")` (their comment says
#   "offline-safe"), and src_prepare symlinks the esmi tarball -- which does
#   provide src/e_smi.c -- into exactly that path, so it never runs. The
#   remaining `git rev-parse` is behind `if(EXISTS "${ESMI_SOURCE_DIR}/.git")`,
#   and a tarball extract has no .git. The patch also commented out
#   `find_program(GIT NAMES git)`, which at 10.0 is dead anyway: GIT is set and
#   consumed nowhere in CMakeLists.txt.
#
#   amdsmi-7.1.1-libdrm-compat.patch -- dropped a duplicate drm_color_ctm_3x4
#   that collided with >=x11-libs/libdrm-2.4.130 (bug 967246). Upstream merged
#   the same change as ROCm/amdsmi PR #165; the struct is gone from
#   include/amd_smi/impl/amdgpu_drm.h at 10.0. Host runs libdrm-2.4.134.

CONFIG_CHECK="~HSA_AMD ~DRM_AMDGPU"

src_prepare() {
	ln -s "${ESMI_S}" esmi_ib_library || die

	# Every sed below asserts its anchor first: `sed` exits 0 on no-match, so
	# an upstream rename would otherwise leave the substitution silently inert
	# with a green build. All anchors verified 2026-08-30 against the
	# therock-10.0 source.
	local f

	# Compatibility with CMake < 3.10 will be removed
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

	# Reset custom installation path -- without this the build installs under
	# its own ROCm prefix instead of the Gentoo one.
	grep -q 'generic_add_rocm' CMakeLists.txt ||
		die "generic_add_rocm anchor moved; the custom ROCm install path would not be reset"
	sed -e "/generic_add_rocm/d" -i CMakeLists.txt || die

	# ::gentoo's 7.2.0 ebuild also carries
	#     sed -e '/target_link_libraries.*\/lib/d' -i goamdsmi_shim/CMakeLists.txt
	# to strip a hardcoded /usr/lib link path for multilib. NOT carried here:
	# upstream fixed it, and at therock-10.0 goamdsmi_shim/CMakeLists.txt has no
	# absolute path left at all -- its only two target_link_libraries calls are
	# bare library names (pthread rt m, and amd_smi). Carrying the sed forward
	# would have been a permanent silent no-op; the anchor assert above it is
	# what caught this. verified 2026-08-30.

	# Install docs to correct place
	# shellcheck disable=SC2016
	grep -q 'doc/${CPACK_PACKAGE_NAME}' CMakeLists.txt ||
		die "docdir anchor moved; docs would install under CPACK_PACKAGE_NAME"
	sed -e "s:doc/\${CPACK_PACKAGE_NAME}:doc/${P}:" -i CMakeLists.txt || die

	# Do not install /usr/share/doc/${P}-asan
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
	# GPU access in amdsmitstReadOnly.TestSysInfoRead and amdsmitstReadOnly.TestIdInfoRead
	addwrite /dev/dri/renderD128

	# Few tests fail on ASUS GZ302E: no metrics from kernel?
	GTEST_FILTER="-amdsmitstReadOnly.TempRead:amdsmitstReadOnly.TestFrequenciesRead" \
	"${BUILD_DIR}/tests/amd_smi_test/amdsmitst" || die "Test failed"
}

src_install() {
	cmake_src_install

	# Wrong places
	rm "${ED}"/usr/share/amd_smi/amdsmi/{libamd_smi.so,LICENSE,README.md} || die

	python_fix_shebang "${ED}"/usr/libexec/amdsmi_cli
	python_domodule "${ED}"/usr/libexec/amdsmi_cli
	python_domodule "${ED}"/usr/share/amd_smi/amdsmi

	fperms a+x "/usr/lib/${EPYTHON}/site-packages/amdsmi_cli/amdsmi_cli.py"
	dosym -r "/usr/lib/${EPYTHON}/site-packages/amdsmi_cli/amdsmi_cli.py" /usr/bin/amd-smi

	rm -rf "${ED}"/usr/share/amd_smi "${ED}"/usr/libexec/amdsmi_cli || die
}
