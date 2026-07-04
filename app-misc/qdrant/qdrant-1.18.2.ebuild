# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.94.0"

inherit cargo systemd

DESCRIPTION="High-performance vector database and vector similarity search engine"
HOMEPAGE="
	https://qdrant.tech/
	https://github.com/qdrant/qdrant
"
SRC_URI="https://github.com/qdrant/qdrant/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

# Qdrant itself is Apache-2.0; its ~870 crate dependencies carry the usual
# permissive Rust mix (MIT/Apache-2.0/BSD/...), fetched by cargo at build time.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Cargo.lock pulls 3 crates from git (tikv/raft-rs at a pinned rev and qdrant's
# tonic fork) that are not on crates.io, so the dependency graph is fetched by
# cargo at build time rather than vendored via CRATES. Hence network access +
# the non-determinism marker.
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
	# --locked builds exactly the Cargo.lock graph; network-sandbox is lifted
	# (RESTRICT) so cargo can fetch crates.io and the pinned git dependencies.
	cargo build --release --locked --bin qdrant \
		|| die "cargo build failed"
}

src_install() {
	dobin target/release/qdrant

	# Config with the storage/snapshot paths pointed at /var/lib/qdrant and
	# the service bound to loopback by default (privacy-first; widen in
	# /etc/qdrant/config.yaml if remote access is wanted).
	sed -e 's#\./storage#/var/lib/qdrant/storage#' \
		-e 's#\./snapshots#/var/lib/qdrant/snapshots#' \
		-e 's#host: 0\.0\.0\.0#host: 127.0.0.1#' \
		config/config.yaml > "${T}/config.yaml" || die
	insinto /etc/qdrant
	newins "${T}/config.yaml" config.yaml

	# Note: the web-UI dashboard is a separate upstream release
	# (qdrant/qdrant-web-ui) and is not bundled in the server source, so it
	# is not installed here; the REST and gRPC APIs work without it.

	keepdir /var/lib/qdrant/storage /var/lib/qdrant/snapshots /var/log/qdrant
	fowners -R qdrant:qdrant /var/lib/qdrant /var/log/qdrant
	fperms 0750 /var/lib/qdrant /var/log/qdrant

	newinitd "${FILESDIR}/qdrant.initd" qdrant
	newconfd "${FILESDIR}/qdrant.confd" qdrant
	systemd_dounit "${FILESDIR}/qdrant.service"

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
