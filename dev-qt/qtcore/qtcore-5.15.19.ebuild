# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV="r0-0"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~x86"
fi

QT5_MODULE="qtbase"
inherit linux-info flag-o-matic toolchain-funcs qt5-build

DESCRIPTION="Cross-platform application development framework"
SLOT=5/${QT5_PV}

IUSE="icu old-kernel"

DEPEND="
	dev-libs/double-conversion:=
	dev-libs/glib:2
	dev-libs/libpcre2[pcre16,unicode]
	virtual/zlib:=
	icu? ( dev-libs/icu:= )
	!icu? ( virtual/libiconv )
"
# NonexistentBlocker warnings are expected because older Qt 5 left the repos,
# but may remain installed. Keep these blockers: split Qt modules cannot mix
# versions. # verified 2026-07-27
RDEPEND="${DEPEND}
	!<dev-qt/qtconcurrent-${QT5_PV}:5
	!<dev-qt/qtdbus-${QT5_PV}:5
	!<dev-qt/qtdeclarative-${QT5_PV}:5
	!<dev-qt/qtgraphicaleffects-${QT5_PV}:5
	!<dev-qt/qtgui-${QT5_PV}:5
	!<dev-qt/qthelp-${QT5_PV}:5
	!<dev-qt/qtmultimedia-${QT5_PV}:5
	!<dev-qt/qtnetwork-${QT5_PV}:5
	!<dev-qt/qtopengl-${QT5_PV}:5
	!<dev-qt/qtprintsupport-${QT5_PV}:5
	!<dev-qt/qtquickcontrols-${QT5_PV}:5
	!<dev-qt/qtquickcontrols2-${QT5_PV}:5
	!<dev-qt/qtsql-${QT5_PV}:5
	!<dev-qt/qtsvg-${QT5_PV}:5
	!<dev-qt/qttest-${QT5_PV}:5
	!<dev-qt/qtwayland-${QT5_PV}:5
	!<dev-qt/qtwebchannel-${QT5_PV}:5
	!<dev-qt/qtwidgets-${QT5_PV}:5
	!<dev-qt/qtx11extras-${QT5_PV}:5
	!<dev-qt/qtxml-${QT5_PV}:5
"

QT5_TARGET_SUBDIRS=(
	src/tools/bootstrap
	src/tools/moc
	src/tools/rcc
	src/corelib
	src/tools/qlalr
	doc
)

QT5_GENTOO_PRIVATE_CONFIG=(
	!:network
	!:sql
	!:testlib
	!:xml
)

pkg_pretend() {
	use kernel_linux || return
	get_running_version
	if kernel_is -lt 4 11 && ! use old-kernel; then
		ewarn "The running kernel is older than 4.11. USE=old-kernel is needed for"
		ewarn "dev-qt/qtcore to function on this kernel properly. Bugs #669994, #672856"
	fi
}

src_prepare() {
	# Prevent upstream -O3 (bug #549140).
	sed -i -e '/CONFIG\s*+=/s/optimize_full//' src/corelib/corelib.pro || die

	# Preserve qt_version_tag with LTO (bug #674382).
	sed -i -e 's/^gcc:ltcg/gcc/' src/corelib/global/global.pri || die

	# Qt breaks with _FORTIFY_SOURCE=3. Replace toolchain or user settings with 2
	# when optimization permits (bug #847145, GCC #105078/#105709, QTBUG-103782).
	if tc-enables-fortify-source ; then
		# Fortification requires optimization.
		filter-flags -D_FORTIFY_SOURCE=3
		# Qt does not reliably respect CPPFLAGS here.
		append-flags -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2
	fi

	qt5-build_src_prepare

	# Regenerate headers added by the QMutex patch.
	qt5_syncqt_version
}

src_configure() {
	local myconf=(
		$(qt_use icu)
		$(qt_use !icu iconv)
	)
	use old-kernel && myconf+=(
		-no-feature-renameat2 # needs Linux 3.16, bug 669994
		-no-feature-getentropy # needs Linux 3.17, bug 669994
		-no-feature-statx # needs Linux 4.11, bug 672856
	)
	qt5-build_src_configure
}

src_install() {
	qt5-build_src_install
	qt5_symlink_binary_to_path qmake 5

	local flags=(
		DBUS FREETYPE IMAGEFORMAT_JPEG IMAGEFORMAT_PNG
		OPENGL OPENSSL SSL WIDGETS
	)

	for flag in ${flags[@]}; do
		cat >> "${D}"/${QT5_HEADERDIR}/QtCore/qconfig.h <<- _EOF_ || die

			#if defined(QT_NO_${flag}) && defined(QT_${flag})
			# undef QT_NO_${flag}
			#elif !defined(QT_NO_${flag}) && !defined(QT_${flag})
			# define QT_NO_${flag}
			#endif
		_EOF_
	done
}
