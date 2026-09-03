# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="a client library to interact with the Hugging Face Hub"
HOMEPAGE="
	https://pypi.org/project/huggingface-hub/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="torch"

# Three upstream requirements carry a major cap that is not mirrored here -
# click<9.0.0, hf-xet<2.0.0 and httpx<1. None binds: the newest anywhere is
# click-8.4.2, hf_xet-1.5.2 and httpx-0.28.1-r1. The click floor (raised to
# 8.4.2 to skip 8.4.0/8.4.1, which shipped a broken fish completion script)
# and the hf-xet floor (1.27.0 raised it to 1.5.2) are both mirrored.
# httpx is deprecated in ::gentoo, but it remains a mandatory upstream
# dependency. Keep it until huggingface_hub provides a supported replacement.
# verified 2026-09-03 against 1.30.0
RDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/click-8.4.2[${PYTHON_USEDEP}]
		<dev-python/click-9[${PYTHON_USEDEP}]
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/fsspec[${PYTHON_USEDEP}]
		<dev-python/httpx-1[${PYTHON_USEDEP}]
		dev-python/packaging[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		>=sci-ml/hf_xet-1.5.2[${PYTHON_USEDEP}]
		<sci-ml/hf_xet-2[${PYTHON_USEDEP}]
		torch? (
			sci-ml/safetensors[${PYTHON_USEDEP}]
		)
	')
	torch? (
		sci-ml/caffe2[${PYTHON_SINGLE_USEDEP}]
		sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	)
"

BDEPEND="
	test? (
		$(python_gen_cond_dep '
			dev-python/jedi[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pillow[${PYTHON_USEDEP}]
		')
		sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
		dev-vcs/git-lfs
	)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-env pytest-mock )

distutils_enable_tests pytest

src_test() {
	local EPYTEST_IGNORE=(
		tests/test_buckets.py
		tests/test_buckets_cli.py
		tests/test_buckets_hf_file_system.py
		tests/test_cache_layout.py
		tests/test_cli_discussions.py
		tests/test_copy_files.py
		tests/test_file_download.py
		tests/test_hf_api.py
		tests/test_hf_file_system.py
		tests/test_hub_mixin.py
		tests/test_hub_mixin_pytorch.py
		tests/test_kernels.py
		tests/test_oauth.py
		tests/test_repocard.py
		tests/test_snapshot_download.py
		tests/test_webhooks_server.py
	)

	local EPYTEST_DESELECT=(
		tests/test_inference_client.py::TestOpenAsMimeBytes
		tests/test_inference_client.py::TestHeadersAndCookies
		tests/test_inference_client.py::test_as_url_with_pil_image
		tests/test_cli.py::TestRepoListCommand::test_repo_list
		tests/test_xet_upload.py::TestXetUpload::test_upload_file
		tests/test_xet_upload.py::TestXetUpload::test_upload_file_with_bytesio
		tests/test_xet_upload.py::TestXetUpload::test_upload_file_with_byte_array
		tests/test_xet_upload.py::TestXetUpload::test_fallback_to_lfs_when_xet_not_available
		tests/test_xet_upload.py::TestXetUpload::test_upload_folder
		tests/test_xet_upload.py::TestXetUpload::test_upload_folder_create_pr
		tests/test_xet_upload.py::TestXetLargeUpload
		tests/test_xet_upload.py::TestXetE2E::test_hf_xet_with_token_refresher
		tests/test_cache_no_symlinks.py::TestCacheLayoutIfSymlinksNotSupported::test_download_no_symlink_existing_file
		tests/test_cache_no_symlinks.py::TestCacheLayoutIfSymlinksNotSupported::test_download_no_symlink_new_file
		tests/test_cache_no_symlinks.py::TestCacheLayoutIfSymlinksNotSupported::test_scan_and_delete_cache_no_symlinks
		tests/test_commit_scheduler.py::TestCommitScheduler::test_context_manager
		tests/test_commit_scheduler.py::TestCommitScheduler::test_missing_folder_is_created
		tests/test_commit_scheduler.py::TestCommitScheduler::test_mocked_push_to_hub
		tests/test_commit_scheduler.py::TestCommitScheduler::test_sync_and_squash_history
		tests/test_commit_scheduler.py::TestCommitScheduler::test_sync_local_folder
		tests/test_inference_async_client.py::test_async_generate_timeout_error
		tests/test_inference_providers.py::TestHFInferenceProvider::test_prepare_mapping_info_unknown_task
		tests/test_offline_utils.py::test_offline_with_timeout
		tests/test_utils_cache.py::TestValidCacheUtils::test_scan_cache_on_valid_cache_unix
		tests/test_utils_cache.py::TestCorruptedCacheUtils
		tests/test_utils_http.py::TestUniqueRequestId
		tests/test_utils_http.py::test_client_get_request
		tests/test_utils_http.py::test_async_client_get_request
		tests/test_utils_pagination.py::TestPagination::test_paginate_hf_api
		tests/test_utils_telemetry.py::TestSendTelemetry::test_topic_multiple
		tests/test_utils_telemetry.py::TestSendTelemetry::test_topic_normal
		tests/test_utils_telemetry.py::TestSendTelemetry::test_topic_quoted
		tests/test_utils_telemetry.py::TestSendTelemetry::test_topic_with_subtopic
		tests/test_xet_download.py::TestXetFileDownload::test_get_xet_file_metadata_basic
		tests/test_xet_download.py::TestXetFileDownload::test_basic_download
		tests/test_xet_download.py::TestXetFileDownload::test_try_to_load_from_cache
		tests/test_xet_download.py::TestXetFileDownload::test_cache_reuse
		tests/test_xet_download.py::TestXetFileDownload::test_download_to_local_dir
		tests/test_xet_download.py::TestXetFileDownload::test_force_download
		tests/test_xet_download.py::TestXetSnapshotDownload
		tests/test_xet_upload.py::TestBucketXetUploadSkipSha256
		tests/test_xet_upload.py::TestXetE2E
	)

	distutils-r1_src_test
}

python_test() {
	# These are explicitly marked calls to the production Hub rather than unit
	# tests; staging integrations above are excluded by module or node.
	epytest -m "not production"
}
