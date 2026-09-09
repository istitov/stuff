# stuff documentation

Source for the dedicated [stuff overlay documentation](https://istitov.github.io/stuff/),
built with Material for MkDocs from the orphan `docs` branch.

## Local preview

```sh
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Run the same validation as CI before publishing:

```sh
mkdocs build --strict
```

Pushing this branch deploys through `.github/workflows/pages.yml` after GitHub
Pages is configured to use **GitHub Actions** as its source. Fast-moving package
and version claims should be reconciled against `origin/master` before each
documentation release.
