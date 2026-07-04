# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for the qdrant vector database daemon"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( qdrant )
ACCT_USER_HOME=/var/lib/qdrant
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
