# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-{1..4} luajit )

inherit lua toolchain-funcs

DESCRIPTION="Lua library for GPIO, LED, PWM, SPI, I2C, MMIO and serial I/O in Linux"
HOMEPAGE="https://github.com/vsergeev/lua-periphery"
SRC_URI="https://github.com/vsergeev/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
REQUIRED_USE="${LUA_REQUIRED_USE}"

# The test suite drives real peripherals on specific boards.
RESTRICT="test"

RDEPEND="
	${LUA_DEPS}
	>=dev-libs/c-periphery-2.5.0:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-system-c-periphery.patch
	"${FILESDIR}"/${P}-mmio-read64-hex.patch
)

src_prepare() {
	default
	lua_copy_sources
}

lua_src_compile() {
	pushd "${BUILD_DIR}" || die
	emake \
		CC="$(tc-getCC)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		LUA_INCDIR="$(lua_get_include_dir)"
	popd || die
}

src_compile() {
	lua_foreach_impl lua_src_compile
}

lua_src_install() {
	exeinto "$(lua_get_cmod_dir)"
	doexe "${BUILD_DIR}"/periphery.so
}

src_install() {
	lua_foreach_impl lua_src_install
	dodoc README.md CHANGELOG.md docs/*.md
}
