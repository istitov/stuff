# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )
PYPI_VERIFY_REPO=https://github.com/pydantic/pydantic-extra-types
inherit distutils-r1 optfeature pypi

DESCRIPTION="Extra Pydantic types"
HOMEPAGE="
	https://github.com/pydantic/pydantic-extra-types/
	https://pypi.org/project/pydantic-extra-types/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pydantic-2.5.2[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

# dev-python/uuid-utils is ::guru-only, and the rest of the test harness
# pulls a sprawl of dev-python/* deps not needed at runtime. Skip tests
# in our overlay's fork.
RESTRICT="test"

pkg_postinst() {
	optfeature_header "Optional type support"
	optfeature "PhoneNumber" dev-python/phonenumbers
	optfeature "language_code" dev-python/pycountry
	optfeature "semantic_version" dev-python/semver
	optfeature "mongo_object_id" dev-python/pymongo
}
