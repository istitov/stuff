# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="A user for lemonade"
ACCT_USER_ID=-1
ACCT_USER_HOME=/var/lib/lemonade
ACCT_USER_HOME_PERMS=0750
ACCT_USER_GROUPS=( lemonade )

KEYWORDS="~amd64"

acct-user_add_deps
