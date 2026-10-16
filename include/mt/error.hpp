#pragma once

#include <string>
#include <string_view>
#include <optional>
#include <utility>
#include <variant>

#include <mt/export.hpp>

namespace mt {

enum class ErrorCode {
    invalid_argument,
    not_supported,
    no_device,
    initialization_failed,
    io_error,
    native_error,
    internal_error,
};

constexpr std::string_view error_code_name(ErrorCode code) noexcept {
    switch (code) {
    case ErrorCode::invalid_argument:
        return "invalid_argument";
    case ErrorCode::not_supported:
        return "not_supported";
    case ErrorCode::no_device:
        return "no_device";
    case ErrorCode::initialization_failed:
        return "initialization_failed";
    case ErrorCode::io_error:
        return "io_error";
    case ErrorCode::native_error:
        return "native_error";
    case ErrorCode::internal_error:
        return "internal_error";
    }

    return "unknown";
}

class MT_API Error {
public:
    Error() = default;

    Error(
        ErrorCode code,
        std::string message,
        std::string operation = {})
        : code_(code),
          message_(std::move(message)),
          operation_(std::move(operation)) {}

    ErrorCode code() const noexcept {
        return code_;
    }

    std::string_view message() const noexcept {
        return message_;
    }

    std::string_view operation() const noexcept {
        return operation_;
    }

    explicit operator bool() const noexcept {
        return !message_.empty();
    }

private:
    ErrorCode code_ = ErrorCode::internal_error;
    std::string message_;
    std::string operation_;
};

template <typename T>
class Result {
public:
    static Result success(T value) {
        return Result(std::move(value));
    }

    static Result failure(Error error) {
        return Result(std::move(error));
    }

    bool has_value() const noexcept {
        return std::holds_alternative<T>(storage_);
    }

    explicit operator bool() const noexcept {
        return has_value();
    }

    T& value() & {
        return std::get<T>(storage_);
    }

    const T& value() const & {
        return std::get<T>(storage_);
    }

    T&& value() && {
        return std::get<T>(std::move(storage_));
    }

    Error& error() & {
        return std::get<Error>(storage_);
    }

    const Error& error() const & {
        return std::get<Error>(storage_);
    }

private:
    explicit Result(T value)
        : storage_(std::move(value)) {}

    explicit Result(Error error)
        : storage_(std::move(error)) {}

    std::variant<T, Error> storage_;
};

template <>
class Result<void> {
public:
    static Result success() {
        return Result();
    }

    static Result failure(Error error) {
        Result result;
        result.error_ = std::move(error);
        return result;
    }

    bool has_value() const noexcept {
        return !error_.has_value();
    }

    explicit operator bool() const noexcept {
        return has_value();
    }

    const Error& error() const & {
        return *error_;
    }

private:
    Result() = default;

    std::optional<Error> error_;
};

} // namespace mt

