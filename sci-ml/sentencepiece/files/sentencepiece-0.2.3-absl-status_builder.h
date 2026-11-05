// Gentoo compat shim for absl/status/status_builder.h.
//
// Abseil releases before StatusBuilder was published (::gentoo's 20260107.1
// among them) do not ship this header. sentencepiece only constructs a
// StatusBuilder from a code, streams a message into it and returns it as an
// absl::Status or absl::StatusOr<T>, so this covers exactly that.

#ifndef SENTENCEPIECE_GENTOO_ABSL_STATUS_BUILDER_H_
#define SENTENCEPIECE_GENTOO_ABSL_STATUS_BUILDER_H_

#include <sstream>
#include <utility>

#include "absl/status/status.h"
#include "absl/status/statusor.h"

namespace absl {

class StatusBuilder {
 public:
  explicit StatusBuilder(StatusCode code) : code_(code) {}

  StatusBuilder(const StatusBuilder& other)
      : code_(other.code_), stream_(other.stream_.str()) {}

  template <typename T>
  StatusBuilder& operator<<(const T& value) & {
    stream_ << value;
    return *this;
  }

  template <typename T>
  StatusBuilder&& operator<<(const T& value) && {
    stream_ << value;
    return std::move(*this);
  }

  operator Status() const { return Status(code_, stream_.str()); }

  template <typename T>
  operator StatusOr<T>() const {
    return StatusOr<T>(Status(code_, stream_.str()));
  }

 private:
  StatusCode code_;
  std::ostringstream stream_;
};

}  // namespace absl

#endif  // SENTENCEPIECE_GENTOO_ABSL_STATUS_BUILDER_H_
