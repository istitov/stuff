# Current TeX Live on Gentoo (the stuff mirror)

`::gentoo`'s TeX Live tracks a stabilized, older release. `stuff` carries the
**current** TeX Live — the full `dev-texlive/*` collection set (39 collections)
plus `app-text/texlive-core`, at the **TL2025** and **TL2026** releases (recent
`tlpdb` revisions) — so documents that need newer packages, fonts, or fixes keep
building. The `app-text/texlive` meta itself stays in `::gentoo`; the overlay
provides the higher-versioned collections it pulls.

## Quickstart

!!! tip "Quickstart"
    With the overlay enabled and its keywords accepted ([Setup](../setup.md)),
    emerge the TeX Live meta — the base install plus the XeTeX and LuaTeX
    collections selected by USE flag. As root:

    ```bash title="root #"
    echo "app-text/texlive xetex luatex" >> /etc/portage/package.use/texlive
    emerge -av app-text/texlive
    ```

## What the overlay carries

- **`app-text/texlive-core`** (2025, 2026) — the base TeX Live runtime: the
  engines (`pdftex`, `xetex`, `luatex`, …) and `kpathsea`.
- The full **`dev-texlive/texlive-*`** collection set — **39 collections**
  spanning `texlive-basic`, `texlive-latex` / `latexrecommended` /
  `latexextra`, `texlive-fontsrecommended` / `fontsextra`, `texlive-xetex` /
  `luatex` / `context`, `texlive-mathscience`, `texlive-pictures`,
  `texlive-publishers`, and the `texlive-lang*` language sets — at the 2025 and
  2026 `tlpdb` revisions, with upstream additions / removals / relocations
  tracked per release.
- **`dev-tex/*`** build tooling kept alongside: `biber`, `biblatex`,
  `latexmk`, `minted`, `pgf`, `tex4ht`, `glossaries`, `latex-beamer`,
  `bibtexu`, `latex2pydata`.

## Selecting collections

TeX Live is installed through the `app-text/texlive` meta, whose **USE flags**
pull the matching `dev-texlive/texlive-*` collections from the overlay. Set the
flags for the collections that are wanted, then emerge the meta. As root:

```bash title="root #"
echo "app-text/texlive xetex luatex context science publishers" \
  >> /etc/portage/package.use/texlive
emerge -av app-text/texlive
```

Representative flags: `xetex`, `luatex`, `context` (engines / formats);
`science`, `publishers`, `humanities`, `music`, `games` (subject collections);
and `l10n_*` for the language sets (e.g. `l10n_de`, `l10n_ru`, `l10n_fr`) which
map to the `texlive-lang*` collections. The full flag list is on the
`app-text/texlive` ebuild in `::gentoo`.

A single collection can also be pulled directly — useful to add one set without
touching the meta's USE flags:

```bash title="root #"
emerge -av dev-texlive/texlive-mathscience
```

## Build tooling

Bibliography, build-loop, and conversion tools commonly paired with TeX Live are
carried as first-class packages rather than bundled scripts. As root:

```bash title="root #"
emerge -av dev-tex/latexmk dev-tex/biber dev-tex/minted
```

`latexmk` drives the compile loop, `biber` is the BibLaTeX backend, and `minted`
provides Pygments-backed source highlighting (it needs `dev-python/pygments`,
pulled in as a dependency). A typical build re-runs the engine until references
settle (and calls `biber` automatically), as a normal user:

```bash title="user $"
latexmk -pdf paper.tex
```

!!! warning "`minted` needs `-shell-escape`"
    `minted` shells out to Pygments at compile time, so the document must be
    built with shell-escape enabled, or compilation aborts:

    ```bash title="user $"
    latexmk -pdf -shell-escape paper.tex   # or: pdflatex -shell-escape paper.tex
    ```

The default paper size follows the system **libpaper** setting (TeX Live is
built `--with-system-libpaper`). Gentoo's `app-text/libpaper` ships the `paper`
query tool — there is no Debian-style `paperconfig` script; the default is set
by writing the size name to the config file. System-wide, as root:

```bash title="root #"
echo a4 > /etc/papersize      # or: letter
```

Per-user, `~/.config/papersize` (or the `PAPERSIZE` environment variable)
overrides it; `paper` run with no arguments shows the size in effect.

## Local files and fonts

A class or package not in any collection goes in the user's `TEXMFHOME` tree
(`~/texmf`), laid out per the TeX Directory Structure — e.g. a custom class at
`~/texmf/tex/latex/<name>/<name>.cls`. `kpathsea` searches `TEXMFHOME` live, so
no database rebuild is needed; files added to a *system* tree
(`/usr/local/share/texmf`) need `mktexlsr` run as root.

!!! tip "Using TeX Live fonts in other applications"
    TeX Live's bundled fonts are not visible to Fontconfig by default. To use one
    in XeTeX, LibreOffice, or another app, symlink it into a user font path and
    refresh the cache, as a normal user:

    ```bash title="user $"
    ln -s /usr/share/texmf-dist/fonts/opentype/public/<font> ~/.local/share/fonts/
    fc-cache
    ```

## Caveats

!!! warning "Testing keywords"
    The overlay's TeX Live is `~amd64`. On stable amd64 the `package.accept_keywords`
    entry above is required; expect the usual testing-branch caveats and pin
    versions for reproducibility.

- **Coexistence with `::gentoo`.** The overlay only raises the versions of
  collections and `texlive-core`; the `app-text/texlive` meta and the USE-flag
  mechanism are unchanged, so an existing TeX Live setup upgrades in place.
- **Don't add packages with `tlmgr`.** TeX Live's own `tlmgr` is shipped and
  runs, but on Gentoo the collections are portage-managed — installing or
  updating through `tlmgr` bypasses portage, and those files are clobbered on
  the next `emerge`. Add collections via the meta's USE flags or `dev-texlive/*`.
- **Release granularity.** Collections are versioned `YYYY_p<tlpdb-rev>`. A
  `emerge -uND @world` after `emerge --sync stuff` moves them to the newest
  tracked revision.

## Troubleshooting

- **`Mismatched LaTeX support files detected`** — after a TeX Live upgrade, a
  stale precompiled format (`.fmt`) cached under
  `$(kpsewhich -var-value TEXMFVAR)/web2c` can conflict with the newer
  system files. Remove that `web2c` directory (it is user-local and regenerated
  on demand) and recompile.

## See also

- [TeX Live upstream](https://www.tug.org/texlive/) — releases and the `tlpdb`.
- [Gentoo TeX project](https://wiki.gentoo.org/wiki/Project:TeX) — the `::gentoo`
  TeX Live packaging this overlay layers on.
- [Arch Wiki: TeX Live](https://wiki.archlinux.org/title/TeX_Live) — distro-neutral
  kpathsea / texmf, font, and troubleshooting reference.
