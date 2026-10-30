# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit python-any-r1 cmake prefix

# The final commit of pytorch/kineto, archived on 2026-09-25. PyTorch 2.15
# vendors libkineto in-tree as third_party/kineto; every file of it except
# README.md is byte-identical to this snapshot's libkineto, which adds only
# sample_programs/ and the fmt, googletest and json submodule directories.
# verified 2026-10-29
CommitId=ae1f4eb2db483b0e31952566d6b834f339501dcf

DESCRIPTION="part of the PyTorch Profiler"
HOMEPAGE="https://github.com/pytorch/kineto"
SRC_URI="https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz
	-> ${P}.tar.gz"
S="${WORKDIR}"/${PN}-${CommitId}/libkineto

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
# The ROCm backend needs rocprofiler-sdk (roctracer support is gone), which
# nothing packages yet. verified 2026-10-29
IUSE="cuda test"

RDEPEND="
	dev-libs/dynolog
	cuda? ( dev-util/nvidia-cuda-toolkit:=[profiler] )
"
DEPEND="
	${RDEPEND}
	dev-libs/libfmt
"
BDEPEND="
	test? ( dev-cpp/gtest )
	${PYTHON_DEPS}
"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.4.0_p20250418-AppxClock.patch
	"${FILESDIR}"/${PN}-0.4.0_p20260805-Werror.patch
)

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLIBKINETO_THIRDPARTY_DIR="${EPREFIX}"/usr/include/
		-DKINETO_BUILD_TESTS=OFF # tests require cuda toolkit
	)
	if use cuda; then
		mycmakeargs+=(
			-DKINETO_BACKEND=cuda
			-DCUDA_SOURCE_DIR="${EPREFIX}"/opt/cuda
		)
	else
		mycmakeargs+=( -DKINETO_BACKEND=cpu )
	fi
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-0.4.0_p20260925-gentoo.patch)

	cmake_src_configure
}
