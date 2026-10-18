#include <type_traits>

#include <mt/mt.hpp>

static_assert(std::is_class_v<mt::OffscreenValidationFixture>);

int main() {
    return 0;
}
