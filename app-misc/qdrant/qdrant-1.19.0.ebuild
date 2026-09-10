# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.97.0"

inherit cargo systemd

DESCRIPTION="High-performance vector database and vector similarity search engine"
HOMEPAGE="
	https://qdrant.tech/
	https://github.com/qdrant/qdrant
"
SRC_URI="https://github.com/qdrant/qdrant/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="openrc systemd"

# Cargo.lock includes a pinned git-only raft-rs revision, requiring live
# network fetching.
PROPERTIES="live"
RESTRICT="network-sandbox test"

RDEPEND="
	acct-group/qdrant
	acct-user/qdrant
"
DEPEND="${RDEPEND}"

src_unpack() {
	default
}

src_compile() {
	export CARGO_HOME="${T}/cargo"
	# Fat LTO exhausts common arm64 builders; Thin retains cross-crate
	# optimization with a smaller link-time working set.
	if [[ ${ARCH} == arm64 ]]; then
		export CARGO_PROFILE_RELEASE_LTO="thin"
	fi
	# --locked fixes the graph while RESTRICT permits its network fetches.
	cargo build --release --locked --bin qdrant \
		|| die "cargo build failed"
}

src_install() {
	dobin target/release/qdrant

	# Move mutable data under /var and bind to loopback by default.
	sed -e 's#\./storage#/var/lib/qdrant/storage#' \
		-e 's#\./snapshots#/var/lib/qdrant/snapshots#' \
		-e 's#host: 0\.0\.0\.0#host: 127.0.0.1#' \
		config/config.yaml > "${T}/config.yaml" || die
	insinto /etc/qdrant
	newins "${T}/config.yaml" config.yaml

	# The separately released web UI is not bundled; REST/gRPC work without it.

	keepdir /var/lib/qdrant/storage /var/lib/qdrant/snapshots /var/log/qdrant
	fowners -R qdrant:qdrant /var/lib/qdrant /var/log/qdrant
	fperms 0750 /var/lib/qdrant /var/log/qdrant

	if use openrc; then
		newinitd "${FILESDIR}/qdrant.initd" qdrant
		newconfd "${FILESDIR}/qdrant.confd" qdrant
	fi
	if use systemd; then
		systemd_dounit "${FILESDIR}/qdrant.service"
	fi

	dodoc README.md
}

pkg_postinst() {
	elog "Qdrant config:   ${EROOT}/etc/qdrant/config.yaml (bound to 127.0.0.1)"
	elog "Qdrant data:     ${EROOT}/var/lib/qdrant"
	elog "REST API:        http://127.0.0.1:6333"
	elog "gRPC API:        127.0.0.1:6334"
	elog
	elog "Start it with:   rc-service qdrant start   (or: systemctl start qdrant)"
}
