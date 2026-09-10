# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{12..14} )

# Keep the last pre-0.137 release: model-hosting-container-standards requires
# flat router.routes, and vllm caps FastAPI below 0.137. Drop when that cap
# lifts. verified 2026-07-27

inherit distutils-r1 optfeature

DESCRIPTION="FastAPI framework, high performance, easy to learn, ready for production"
HOMEPAGE="
	https://fastapi.tiangolo.com/
	https://pypi.org/project/fastapi/
	https://github.com/fastapi/fastapi
"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/fastapi/fastapi.git"
else
	inherit pypi
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	>=dev-python/annotated-doc-0.0.2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.9.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.46.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.8.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.2[${PYTHON_USEDEP}]
"
# Full tests require several ::guru-only dependencies; rely on upstream CI.
RESTRICT="test"

python_prepare_all() {
	# Omit the executable provided by fastapi-cli.
	sed -i -e '/\[project.scripts\]/,/^$/d' pyproject.toml || die

	distutils-r1_python_prepare_all
}

pkg_postinst() {
	optfeature "test client" dev-python/httpx
	optfeature "templates" dev-python/jinja2
	optfeature "forms and file uploads" dev-python/python-multipart
	optfeature "validate emails" dev-python/email-validator
	optfeature "uvicorn with uvloop" dev-python/uvicorn
	optfeature "settings management" dev-python/pydantic-settings
	optfeature "extra Pydantic data types" dev-python/pydantic-extra-types
	optfeature "session middleware support" dev-python/itsdangerous
	optfeature "YAML support" dev-python/pyyaml
	optfeature_header "Alternative JSON responses"
	optfeature "ORJSONResponse" dev-python/orjson
	optfeature "UJSONResponse" dev-python/ujson
}
