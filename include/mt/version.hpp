#pragma once

#include <cstdint>

#include <mt/export.hpp>

namespace mt {

inline constexpr uint32_t kVersionMajor = 0;
inline constexpr uint32_t kVersionMinor = 1;
inline constexpr uint32_t kVersionPatch = 0;

inline constexpr const char* library_version() noexcept {
    return "0.1.0";
}

} // namespace mt

