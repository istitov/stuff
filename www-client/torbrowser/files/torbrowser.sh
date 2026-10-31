#!/bin/sh
# Use the system net-vpn/tor service through its default SOCKS port. Set
# TOR_PROVIDER=tor to use a control port instead, as described in the
# package's pkg_postinst message.
: "${TOR_PROVIDER:=none}"
export TOR_PROVIDER

# Both of these turn the proxy off without a visible error: DNS stays blocked,
# but URLs with an IP address go out directly. TOR_TRANSPROXY does so by merely
# existing, and a port the browser rejects leaves a saved port 0 in place, which
# Unix socket setups store in the profile. verified 2026-11-01
unset TOR_TRANSPROXY
if [ -z "${TOR_SOCKS_IPC_PATH+x}" ]; then
	case ${TOR_SOCKS_PORT-} in
		"" | *[!0-9]* | ??????*) TOR_SOCKS_PORT=9050 ;;
	esac
	if [ "${TOR_SOCKS_PORT}" -lt 1 ] || [ "${TOR_SOCKS_PORT}" -gt 65535 ]; then
		TOR_SOCKS_PORT=9050
	fi
	export TOR_SOCKS_PORT
fi

# From upstream's start-tor-browser, to avoid leaving traces on disk
unset SESSION_MANAGER
GSETTINGS_BACKEND=memory
__GL_SHADER_DISK_CACHE=0
export GSETTINGS_BACKEND __GL_SHADER_DISK_CACHE

# The bundled fonts.conf of USE=vanilla finds its fonts relative to the cwd
if [ -f "@MOZILLA_FIVE_HOME@/fonts/fonts.conf" ]; then
	cd "@MOZILLA_FIVE_HOME@" || exit
fi

exec "@MOZILLA_FIVE_HOME@/torbrowser" "$@"
