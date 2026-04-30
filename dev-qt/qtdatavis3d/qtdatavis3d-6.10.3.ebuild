# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qt6-build

DESCRIPTION="Data Visualization component library for the Qt6 framework"

if [[ ${QT6_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64"
fi

# QtDataVisualization is an OpenGL-based 3D scatter/surface/bar viewer.
# Deprecated upstream as of Qt 6.6 in favour of QtGraphs but still
# shipped through Qt 6.10. Resurrected in this overlay because
# sci-physics/sasview's Shape2SAS calculator hard-imports
# PySide6.QtDataVisualization and ::gentoo dropped this submodule
# during the Qt6 import.

RDEPEND="
	~dev-qt/qtbase-${PV}:6[gui,opengl,widgets]
	~dev-qt/qtdeclarative-${PV}:6
"
DEPEND="${RDEPEND}"
