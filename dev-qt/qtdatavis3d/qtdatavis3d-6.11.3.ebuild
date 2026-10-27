# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qt6-build

DESCRIPTION="Data Visualization component library for the Qt6 framework"

if [[ ${QT6_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64 ~arm64"
fi

# Deprecated in favor of QtGraphs but retained because SasView's Shape2SAS
# calculator imports PySide6.QtDataVisualization; ::gentoo dropped this Qt6
# submodule.

RDEPEND="
	~dev-qt/qtbase-${PV}:6[gui,opengl,widgets]
	~dev-qt/qtdeclarative-${PV}:6
"
DEPEND="${RDEPEND}"
