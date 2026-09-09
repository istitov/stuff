# Keeping Qt5 alive on Gentoo (the stuff 5.15 LTS mirror)

`::gentoo` last-rited the entire `dev-qt` **slot 5** set on 2026-05-15
([bug #948836](https://bugs.gentoo.org/948836)) — "last rites" is Gentoo's
formal removal announcement, and a **slot** is Gentoo's mechanism for keeping
incompatible major versions installed side by side (for example, Qt5 = `:5`
and Qt6 = `:6`) — and no longer carries the slot-5 split set. Plenty of
software hasn't finished its Qt6 port, including large scientific GUIs such as
`sci-physics/mantid`, PyQt5 apps, and qscintilla-based editors.

`stuff` carries the Qt5 split-module set at **5.15.19-lts-lgpl**, excluding
QtWebEngine, with the [**KDE Qt5 Patch Collection**][1] applied, so those apps
keep building. It's a deliberate
**bridge**, not a destination — it exists until its consumers move to Qt6.

## Quickstart

!!! tip "Quickstart"
    With the overlay enabled and its keywords accepted ([Setup](../setup.md)),
    emerge a Qt5 consumer; it resolves against the overlay's 5.15.19. The
    overlay's profile re-allows the masked `dev-qt:5` set, so no manual unmask is
    needed. As root:

    ```bash title="root #"
    emerge -av sci-physics/mantid        # example Qt5 consumer
    ```

## What the overlay carries

- The `dev-qt` **slot 5** split-module set at **5.15.19-lts-lgpl**, except
  QtWebEngine — Qt Group's LTS
  release (2025-11-25, which `::gentoo` never picked up), with the **KDE Qt5
  Patch Collection** applied on top. That's newer than `::gentoo`'s final
  5.15.18.
- `dev-python/pyqt5` (5.15.11) + `dev-python/pyqt5-sip` — PyQt5 revived after
  `::gentoo`'s treeclean.
- `x11-libs/qscintilla-2.14.1-r1` — the last Qt5-compatible qscintilla. The
  Qt6-only `-r2` is masked in the overlay so portage keeps `-r1`.

## How to use it

1. **Enable the overlay.** Its `profiles/package.unmask` re-allows the
   `dev-qt/*:5` set that `::gentoo` masked — applied automatically for anyone
   with the overlay enabled, so nothing is unmasked by hand.
2. **Accept `~arch` keywords.** The Qt5 ebuilds are keyworded testing
   (`~amd64 …`). On stable amd64, accept them. The simplest form takes the whole
   overlay:
   ```text title="/etc/portage/package.accept_keywords/stuff"
   */*::stuff ~amd64
   ```
   or scope it to just the Qt5 pieces:
   ```text title="/etc/portage/package.accept_keywords/stuff"
   dev-qt/*::stuff       ~amd64
   dev-python/pyqt5      ~amd64
   dev-python/pyqt5-sip  ~amd64
   x11-libs/qscintilla   ~amd64
   ```
3. **Emerge the Qt5 consumer.** It resolves its `dev-qt/*:5` dependencies
   against the overlay's 5.15.19. The set can also be pulled directly
   (`emerge -av dev-qt/qtcore:5 dev-qt/qtwidgets:5 …`).

## Under the hood

- Each module is built by the overlay's `qt5-build.eclass`. The KDE Qt5 Patch
  Collection is cut per-module and mirrored to
  [extra-stuff](https://github.com/istitov/extra-stuff) as version-pinned
  distfiles; the eclass fans the `SRC_URI` across the GitHub / Codeberg / GitLab
  raw mirrors, while the upstream Qt tarballs come from `download.qt.io`.
- `profiles/package.unmask` re-allows the slot; `profiles/package.mask` pins
  qscintilla to the Qt5 `-r1`.

## When can the mirror be dropped?

The mirror is a bridge: it exists only until its consumers finish their Qt6
ports. To see what still pulls Qt5, list the reverse dependencies of the base
module with `app-portage/gentoolkit`, as a normal user:

```bash title="user $"
equery depends dev-qt/qtcore:5
```

Once nothing but the `dev-qt/*:5` set itself depends on Qt5, the consumers have
moved on and the overlay's Qt5 can be retired — `emerge --deselect` the apps,
then `emerge --depclean`.

## Caveats

!!! warning "It's a temporary bridge"
    This mirror exists so Qt5 consumers keep working *through* their Qt6 ports —
    it will be dropped once those land. Don't start new work against Qt5.

- **`qtwebengine:5` is not carried** (it's masked) — apps that need the Qt5
  WebEngine won't find it here.
- **Tree status.** `::gentoo`'s Qt5 removal has executed. The overlay is now the
  source for this split set, and a Qt5 consumer that isn't using it will fail
  to resolve.
- **How long the mirror lives.** Best-effort, no hard end-of-life date: it is
  maintained while its consumers still need it and retired (archived in git
  history, not erased) once they have moved to Qt6 — the
  [reverse-dependency check above](#when-can-the-mirror-be-dropped) is the
  exit criterion.

## Troubleshooting

- **`Cannot mix incompatible Qt library (version 0x05XXXX)`** — after a Qt5
  point bump, a style or platform-theme plugin built against the previous Qt5
  refuses to load (these use Qt private headers and pin an exact version, not
  just a matching soname). Rebuild the consumers with
  `emerge @preserved-rebuild` (`@preserved-rebuild` is a built-in portage set,
  like `@world`, that rebuilds packages still linked against old library
  copies); Gentoo's subslot dependencies rebuild most Qt5 consumers
  automatically on the bump, and this catches anything left with preserved
  libraries.

!!! tip "Theming Qt5 apps outside KDE"
    Qt5 follows the desktop's theme under KDE / GNOME but falls back to *Fusion*
    elsewhere. Install the `qt5ct` package and set `QT_QPA_PLATFORMTHEME=qt5ct`
    (or force a widget style with `QT_STYLE_OVERRIDE`) to control icons, fonts,
    and style.

!!! tip "Running Qt5 apps on Wayland"
    The overlay carries `dev-qt/qtwayland:5`, so a Qt5 app can use the Wayland
    backend directly with `QT_QPA_PLATFORM=wayland`; otherwise it runs through
    XWayland via the `xcb` plugin.

## See also

- [Arch Wiki: Qt](https://wiki.archlinux.org/title/Qt) — distro-neutral Qt
  configuration, theming, and troubleshooting reference.

[1]: https://invent.kde.org/qt/qt
