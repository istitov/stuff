# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=9

inherit acct-user

DESCRIPTION="A user for lemonade"
ACCT_USER_ID=-1
ACCT_USER_HOME=/var/lib/lemonade
ACCT_USER_HOME_PERMS=0750
# Upstream's .deb and RPM postinst scripts add the user to render for GPU
# access; Gentoo's udev leaves renderD* and kfd 0666 unless an admin
# tightens them. verified 2026-11-13
ACCT_USER_GROUPS=( lemonade render )

KEYWORDS="~amd64"

acct-user_add_deps
