// Gentoo compat shim for absl/status/status_macros.h.
//
// Abseil releases before the status macros were published (::gentoo's
// 20260107.1 among them) do not ship this header. sentencepiece uses only
// ABSL_RETURN_IF_ERROR, never with a streamed message, so this defines that.

#ifndef SENTENCEPIECE_GENTOO_ABSL_STATUS_MACROS_H_
#define SENTENCEPIECE_GENTOO_ABSL_STATUS_MACROS_H_

#include "absl/status/status.h"

#ifndef ABSL_RETURN_IF_ERROR
#define ABSL_RETURN_IF_ERROR(expr)                                \
  do {                                                            \
    const ::absl::Status sp_gentoo_absl_status = (expr);          \
    if (!sp_gentoo_absl_status.ok()) return sp_gentoo_absl_status; \
  } while (false)
#endif

#endif  // SENTENCEPIECE_GENTOO_ABSL_STATUS_MACROS_H_
