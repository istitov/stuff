# Gentoo-local thin-loader replacement for upstream espeakng-loader.
# Upstream PyPI ships per-platform wheels with a bundled
# libespeak-ng.so binary; Gentoo points at system app-accessibility/
# espeak-ng instead. API surface matches upstream 0.2.4.
#
# Hardcoded paths are baked at install time (no autodiscovery) — this
# is the trade for not bundling. If your espeak-ng moves, rebuild.

import ctypes
import os


def get_library_path():
    return "@LIBESPEAK_NG@"


def get_data_path():
    return "@ESPEAK_NG_DATA@"


def load_library():
    try:
        return ctypes.CDLL(get_library_path())
    except OSError as e:
        print(f"Error loading shared library from {get_library_path()}: {e}")
        return None


def make_library_available():
    # System libespeak-ng is on the loader's default path —
    # ld.so.cache resolves it. No-op on Gentoo.
    pass
