#include <cassert>
#include <string_view>

#include <mt/error.hpp>

int main() {
    auto success = mt::Result<int>::success(42);
    assert(success);
    assert(success.value() == 42);

    auto failure = mt::Result<int>::failure(
        mt::Error(mt::ErrorCode::invalid_argument, "bad value", "test"));
    assert(!failure);
    assert(failure.error().code() == mt::ErrorCode::invalid_argument);
    assert(failure.error().message() == std::string_view("bad value"));

    auto void_success = mt::Result<void>::success();
    assert(void_success);

    auto void_failure = mt::Result<void>::failure(
        mt::Error(mt::ErrorCode::internal_error, "failed"));
    assert(!void_failure);
    assert(void_failure.error().code() == mt::ErrorCode::internal_error);

    return 0;
}

