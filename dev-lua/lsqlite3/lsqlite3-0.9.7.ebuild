# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-{1..4} luajit )

inherit edo lua toolchain-funcs

# Fossil builds the zip on request; pin the v0.9.7 check-in rather than
# the tag, which can be moved. Same bytes as the tag URL (verified
# 2026-09-27).
MY_COMMIT="0311791a70c0a8fde2ae38352e88558ae1b8134d"
MY_P="${PN}_v${PV//./}"

DESCRIPTION="Lua binding for the SQLite3 database library"
HOMEPAGE="https://lua.sqlite.org/"
SRC_URI="https://lua.sqlite.org/home/zip/${MY_P}.zip?uuid=${MY_COMMIT} -> ${P}.zip"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"
REQUIRED_USE="${LUA_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	${LUA_DEPS}
	dev-db/sqlite:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-arch/unzip
	test? ( ${RDEPEND} )
"

src_prepare() {
	default

	# The zip carries an SQLite amalgamation for the statically linked
	# lsqlite3complete module. Remove it so the quoted sqlite3.h include
	# cannot resolve to the bundled header instead of the system one.
	rm sqlite3.c sqlite3.h || die

	lua_copy_sources
}

lua_src_compile() {
	pushd "${BUILD_DIR}" || die
	local cmd=(
		$(tc-getCC) ${CFLAGS} -fPIC $(lua_get_CFLAGS)
		-DLSQLITE_VERSION=\"${PV}\"
	)
	# lsqlite3 calls luaL_openlib on Lua 5.1, but ::gentoo's lua:5.1
	# leaves LUA_COMPAT_OPENLIB, which declares it, undefined.
	# verified 2026-09-27
	[[ ${ELUA} == lua5.1 ]] && cmd+=( -DLUA_COMPAT_OPENLIB )
	cmd+=(
		${LDFLAGS} -shared lsqlite3.c -lsqlite3 -o lsqlite3.so
	)
	edo "${cmd[@]}"
	popd || die
}

src_compile() {
	lua_foreach_impl lua_src_compile
}

lua_src_test() {
	pushd "${BUILD_DIR}" || die
	# tests-sqlite3.lua needs lunit, which is not packaged.
	LUA_CPATH="${BUILD_DIR}/?.so" edo ${ELUA} test/test.lua
	popd || die
}

src_test() {
	lua_foreach_impl lua_src_test
}

lua_src_install() {
	exeinto "$(lua_get_cmod_dir)"
	doexe "${BUILD_DIR}"/lsqlite3.so
}

src_install() {
	lua_foreach_impl lua_src_install
	dodoc HISTORY README doc/lsqlite3.wiki
	docinto examples
	dodoc examples/*.lua
}
