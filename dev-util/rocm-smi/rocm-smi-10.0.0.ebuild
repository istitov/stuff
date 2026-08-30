# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake linux-info optfeature python-r1

DESCRIPTION="ROCm System Management Interface Library"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocm-smi-lib"

if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_SUBMODULES=()
	EGIT_REPO_URI="https://github.com/ROCm/rocm-systems.git"
	S="${WORKDIR}/${P}/projects/rocm-smi-lib"
else
	# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
	# per-component assets ship under therock-<major.minor> tags now. ROCm 10.0
	# is the renumbering of the 7.13 -> 7.14 line (2026-08-27), not a jump of
	# three majors. Only the tag changes; the asset name carries no version.
	SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocm-smi-lib.tar.gz -> rocm-smi-${PV}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/rocm-smi-lib"
fi

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	x11-libs/libdrm[video_cards_amdgpu]
"

# ${PN}-5.7.1-no-strip.patch is obsolete at 10.0: upstream removed the
# POST_BUILD ${CMAKE_STRIP} custom commands entirely (zero occurrences of
# CMAKE_STRIP in the whole archive), so portage's own stripping is unopposed.
#
# remove-example is NOT obsolete and is regenerated below. The example target
# survives at 10.0 -- rocm_smi/CMakeLists.txt still builds
# rocm_smi/example/rocm_smi_example.cc -- only the surrounding context moved.
# (An earlier revision of this ebuild wrongly dropped it after checking for an
# example/ directory at the archive root instead of under rocm_smi/.)
# verified 2026-08-30.
PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-remove-example.patch
)

CONFIG_CHECK="~HSA_AMD ~DRM_AMDGPU"

src_prepare() {
	cmake_src_prepare

	# Disable code that relies on missing .git directory.
	# Just silences potential "git: command not found" QA warnings.
	#
	# `sed` exits 0 when it matches nothing, so `|| die` can never catch a
	# stale anchor -- assert each pattern first. 10.0 respelled the first one:
	# it was `find_program (GIT NAMES git)` through 7.2.4 and is now
	# `find_program(GIT NAMES git)` with no space, so the old anchor silently
	# matched nothing. Match both spellings. The other two are unchanged at
	# 10.0 (utils.cmake:130, rsmiBindingsInit.py.in). verified 2026-08-29.
	grep -qE 'find_program ?\(GIT NAMES git\)' CMakeLists.txt ||
		die "GIT find_program anchor moved"
	sed -e "/find_program \?(GIT NAMES git)/d" -i CMakeLists.txt || die

	grep -qF 'num_change_since_prev_pkg(${VERSION_PREFIX})' cmake_modules/utils.cmake ||
		die "num_change_since_prev_pkg anchor moved"
	sed -e "/num_change_since_prev_pkg(\${VERSION_PREFIX})/d" -i cmake_modules/utils.cmake || die

	local rocm_lib="${EPREFIX}/usr/$(get_libdir)/librocm_smi64.so.@VERSION_MAJOR@"
	grep -qE 'path_librocm =.+__file__.+' python_smi_tools/rsmiBindingsInit.py.in ||
		die "path_librocm anchor moved; python bindings would load the wrong soname"
	sed -E "s|path_librocm =.+__file__.+|path_librocm = '${rocm_lib}'|" \
		-i python_smi_tools/rsmiBindingsInit.py.in || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	python_foreach_impl python_newscript python_smi_tools/rocm_smi.py rocm-smi
	python_foreach_impl python_domodule python_smi_tools/rsmiBindings.py
	python_foreach_impl python_domodule python_smi_tools/rsmiBindingsInit.py

	mv "${ED}"/usr/share/doc/rocm-smi-lib/* "${ED}/usr/share/doc/${PF}" || die
	rm -r "${ED}"/usr/share/doc/rocm-smi-lib || die
}

pkg_postinst() {
	optfeature "vendor and device names instead of hex device IDs" sys-apps/hwdata
}
