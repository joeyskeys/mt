#pragma once

#include <cstddef>

#include <mt/export.hpp>

namespace mt {

enum class NativeHandleType {
    none,
    metal_device,
    metal_command_queue,
    metal_command_buffer,
    metal_resource,
    metal_pipeline_state,
    metal_layer,
};

// A borrowed escape hatch for integrations that need the underlying Metal
// object. The handle never transfers ownership.
class MT_API NativeHandle {
public:
    constexpr NativeHandle() noexcept = default;

    static constexpr NativeHandle borrowed(
        void* value,
        NativeHandleType type) noexcept {
        return NativeHandle(value, type);
    }

    constexpr explicit operator bool() const noexcept {
        return value_ != nullptr && type_ != NativeHandleType::none;
    }

    constexpr void* value() const noexcept {
        return value_;
    }

    constexpr NativeHandleType type() const noexcept {
        return type_;
    }

    template <typename T>
    constexpr T* as() const noexcept {
        return static_cast<T*>(value_);
    }

private:
    constexpr NativeHandle(void* value, NativeHandleType type) noexcept
        : value_(value),
          type_(type) {}

    void* value_ = nullptr;
    NativeHandleType type_ = NativeHandleType::none;
};

} // namespace mt

