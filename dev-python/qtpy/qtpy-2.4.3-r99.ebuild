# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_PN=QtPy
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 virtualx pypi

DESCRIPTION="Abstraction layer on top of PyQt and PySide with additional custom QWidgets"
HOMEPAGE="
	https://github.com/spyder-ide/qtpy/
	https://pypi.org/project/QtPy/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"

# This is a fork of ::gentoo's dev-python/qtpy-2.4.3-r2 with one
# functional change: a `pyqt5` USE flag that suppresses the
# PyQt5-disabling sed in src_prepare. ::gentoo unconditionally patches
# qtpy/__init__.py so the PyQt5 import path raises ImportError
# (Gentoo's Qt5 deprecation policy), which means any qtpy consumer
# that targets Qt5 (notably sci-physics/mantid) cannot actually
# load — the import chain dies on `from qtpy.QtWidgets import
# QDesktopWidget` because qtpy falls through to PyQt6 and PyQt6
# removed QDesktopWidget. With USE=pyqt5 enabled, qtpy honours
# QT_API=pyqt5 and routes through dev-python/pyqt5 normally.
_IUSE_QT_MODULES="
	bluetooth dbus designer +gui help multimedia +network nfc opengl pdfium
	positioning printsupport qml quick quick3d remoteobjects scxml sensors
	serialport spatialaudio speech +sql svg testlib vulkan webchannel
	webengine websockets +widgets +xml
"
IUSE="pyqt5 +pyqt6 pyside6 ${_IUSE_QT_MODULES}"
unset _IUSE_QT_MODULES

REQUIRED_USE="
	|| ( pyqt5 pyqt6 pyside6 )
"

RDEPEND="
	dev-python/packaging[${PYTHON_USEDEP}]
	pyqt5? (
		dev-python/pyqt5[${PYTHON_USEDEP},gui?,widgets?]
	)
	pyqt6? (
		dev-python/pyqt6[${PYTHON_USEDEP}]
		dev-python/pyqt6[bluetooth?,dbus?,designer?,gui?,help?,multimedia?]
		dev-python/pyqt6[network?,nfc?,opengl?,pdfium?,positioning?]
		dev-python/pyqt6[printsupport?,qml?,quick?,quick3d?,remoteobjects?]
		dev-python/pyqt6[scxml(-)?,sensors?,serialport?,spatialaudio?,speech?]
		dev-python/pyqt6[sql?,svg?,testlib?,vulkan?,webchannel?,websockets?]
		dev-python/pyqt6[widgets?,xml?]
		webengine? ( dev-python/pyqt6-webengine[${PYTHON_USEDEP},widgets?,quick?] )
	)
	pyside6? (
		dev-python/pyside:6[${PYTHON_USEDEP},core(+)]
		dev-python/pyside:6[bluetooth?,dbus?,designer?,gui?,help?,multimedia?]
		dev-python/pyside:6[network?,nfc?,opengl?,pdfium?,positioning?]
		dev-python/pyside:6[printsupport?,qml?,quick?,quick3d?,remoteobjects(-)?]
		dev-python/pyside:6[scxml?,sensors?,serialport?,spatialaudio?,speech?]
		dev-python/pyside:6[sql?,svg?,testlib?,vulkan(+)?,webchannel?,webengine?]
		dev-python/pyside:6[websockets?,widgets?,xml?]
	)
"

BDEPEND="
	test? (
		pyqt6? (
			dev-python/pyqt6[${PYTHON_USEDEP}]
			dev-python/pyqt6[bluetooth,dbus,designer,gui,help,multimedia]
			dev-python/pyqt6[network,nfc,opengl,pdfium,positioning,printsupport]
			dev-python/pyqt6[qml,quick,quick3d,scxml(-),sensors,serialport]
			dev-python/pyqt6[spatialaudio,speech,sql,svg,testlib,webchannel]
			dev-python/pyqt6[vulkan(-),websockets,widgets,xml]
			dev-python/pyqt6-webengine[${PYTHON_USEDEP},widgets,quick]
			dev-qt/qtbase:6[sqlite]
		)
		pyside6? (
			dev-python/pyside:6[${PYTHON_USEDEP},core(+)]
			dev-python/pyside:6[3d,bluetooth,charts,concurrent,dbus,designer,gui]
			dev-python/pyside:6[help,location,multimedia,network,network-auth]
			dev-python/pyside:6[nfc,opengl,pdfium,positioning,printsupport,qml]
			dev-python/pyside:6[quick,quick3d,scxml,sensors,serialport]
			dev-python/pyside:6[spatialaudio,speech,sql,svg,testlib,vulkan(+)]
			dev-python/pyside:6[webchannel,webengine,websockets,widgets,xml]
			dev-qt/qtbase:6[sqlite]
		)
	)
"

EPYTEST_PLUGINS=( pytest-qt )
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# Disable PyQt5 only when USE=pyqt5 is off — preserves ::gentoo's
	# default Qt5-deprecation behaviour. When USE=pyqt5 is on, leave
	# the PyQt5 detection path intact.
	if ! use pyqt5; then
		sed \
			-e '/from PyQt5.QtCore import/,/)/c\ \ \ \ \ \ \ \ raise ImportError #/' \
			-e '/if "PyQt5" in sys.modules:/,/"pyqt5"/c\' \
			-i qtpy/__init__.py || die
	fi

	# Always promote the next sys.modules check to a fresh `if` so a
	# disabled binding above doesn't strand it as `elif`.
	sed -e 's/elif "PySide2" in sys.modules:/if "PySide2" in sys.modules:/g' \
		-i qtpy/__init__.py || die

	# Always disable PySide2 — there is no `pyside2` USE flag here
	# either; if a future use case demands it the same pattern as the
	# pyqt5 gate applies.
	sed \
		-e "s/from PySide2 import/raise ImportError #/" \
		-e "s/from PySide2.QtCore import/raise ImportError #/" \
		-e '/if "PySide2" in sys.modules:/,/"pyside2"/c\' \
		-i qtpy/__init__.py || die

	sed \
		-e 's/elif "PyQt6" in sys.modules:/if "PyQt6" in sys.modules:/g' \
		-i qtpy/__init__.py || die

	if ! use pyqt6; then
		sed \
			-e '/from PyQt6.QtCore import/,/)/c\ \ \ \ \ \ \ \ raise ImportError #/' \
			-e '/if "PyQt6" in sys.modules:/,/"pyqt6"/c\' \
			-i qtpy/__init__.py || die

		sed \
			-e 's/elif "PySide6" in sys.modules:/if "PySide6" in sys.modules:/g' \
			-i qtpy/__init__.py || die
	fi
	if ! use pyside6; then
		sed \
			-e "s/from PySide6 import/raise ImportError #/" \
			-e "s/from PySide6.QtCore import/raise ImportError #/" \
			-e '/if "PySide6" in sys.modules:/,/"pyside6"/c\' \
			-i qtpy/__init__.py || die
	fi
}

python_test() {
	local -x QT_API
	local -a EPYTEST_DESELECT
	local other

	for QT_API in PyQt5 PyQt6 PySide6; do
		if use "${QT_API,,}"; then
			EPYTEST_DESELECT=()
			for other in PyQt{5,6} PySide{2,6}; do
				if [[ ${QT_API} != ${other} ]]; then
					EPYTEST_DESELECT+=(
						"qtpy/tests/test_main.py::test_qt_api_environ[${other}]"
					)
				fi
			done

			einfo "Testing with ${EPYTHON} and QT_API=${QT_API}"
			nonfatal epytest -o addopts= ||
				die -n "Tests failed with ${EPYTHON} and QT_API=${QT_API}" ||
				return 1
		fi
	done
}

src_test() {
	virtx distutils-r1_src_test
}

pkg_postinst() {
	elog "When multiple Qt4Python targets are enabled QtPy will default"
	elog "to the first available target in this order:"
	elog "    PyQt5 (if USE=pyqt5) -> PyQt6 -> PySide6."
	elog "Override with the QT_API environment variable. For Mantid"
	elog "(sci-physics/mantid) which is Qt5-only, set QT_API=pyqt5."
}
