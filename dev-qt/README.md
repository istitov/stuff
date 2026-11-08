# dev-qt — Qt5 LTS mirror

`::gentoo` removed its `dev-qt:5` packages in 2026 (bug
[#948836](https://bugs.gentoo.org/948836)). This category keeps the slot 5
split-module set alive at **5.15.19-lts-lgpl**, without QtWebEngine, with the
[KDE Qt5 Patch Collection](https://invent.kde.org/qt/qt) applied through the
overlay's `qt5-build.eclass`. That is newer than `::gentoo`'s final 5.15.18.

It serves `dev-python/pyqt5` and overlay packages that can still be built
against Qt5 with `USE=qt5`, such as
`games-roguelike/dwarftherapist`, `sci-physics/mantid` 6.16.1.1 and
`sci-physics/prismatic` (Qt6 is their default). The last Qt5-compatible
`x11-libs/qscintilla` is in the overlay too. The mirror goes away once nothing
needs Qt5.

The [Qt5 LTS guide](https://istitov.github.io/stuff/guides/qt5-lts/) covers
installing a Qt5 consumer and checking what still depends on Qt5.

Two Qt6 packages also live here: `qtdatavis3d` and a 6.11 `qtsvg`.
