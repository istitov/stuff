# stuff documentation

Source for the dedicated [stuff overlay documentation](https://istitov.github.io/stuff/),
built with [Zensical](https://zensical.org) from the orphan `docs` branch.
Zensical reads `mkdocs.yml` directly; `variant: classic` keeps the Material
for MkDocs look.

## Local preview

Zensical is packaged in this overlay as `dev-python/zensical`:

```sh
emerge --ask dev-python/zensical
zensical serve
```

CI installs the version pinned in `requirements.txt` with pip instead.

Run the same validation as CI before publishing:

```sh
zensical build --strict --clean
```

Pushing this branch deploys through `.github/workflows/pages.yml` after GitHub
Pages is configured to use **GitHub Actions** as its source. Fast-moving package
and version claims should be reconciled against `origin/master` before each
documentation release.
