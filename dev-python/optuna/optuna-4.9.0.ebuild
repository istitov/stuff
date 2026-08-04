# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

DESCRIPTION="Hyperparameter optimization framework"
HOMEPAGE="
	https://optuna.org/
	https://github.com/optuna/optuna
	https://pypi.org/project/optuna/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/alembic-1.5.0[${PYTHON_USEDEP}]
	dev-python/colorlog[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/packaging-20[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-1.4.2[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/fakeredis[${PYTHON_USEDEP}]
		dev-python/grpcio[${PYTHON_USEDEP}]
		>=dev-python/protobuf-5.28.1[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	)
"

EPYTEST_IGNORE=(
	# require optional dependencies
	tests/artifacts_tests/test_boto3.py
	tests/artifacts_tests/test_gcs.py
	tests/gp_tests
	tests/importance_tests
	tests/samplers_tests/test_cmaes.py
	tests/samplers_tests/test_gp.py
	tests/samplers_tests/test_partial_fixed.py
	tests/samplers_tests/test_samplers.py
	tests/study_tests/test_dataframe.py
	tests/test_cli.py
	tests/visualization_tests
)
EPYTEST_DESELECT=(
	# require cmaes, which is not packaged
	"tests/pruners_tests/test_hyperband.py::test_hyperband_filter_study[<lambda>3]"
	"tests/pruners_tests/test_hyperband.py::test_hyperband_no_filter_study[<lambda>3]"
	"tests/pruners_tests/test_hyperband.py::test_hyperband_no_call_of_filter_study_in_should_prune[<lambda>3]"
	# pytest injects its own handlers into the logger under test
	tests/test_logging.py::test_default_handler
	tests/test_logging.py::test_propagation
)

python_test() {
	# require fakeredis[lua], whose lupa dependency is not packaged
	epytest -k "not (journal_redis or redis_default or redis_with_use_cluster)"
}
