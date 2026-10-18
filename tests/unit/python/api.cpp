#include <type_traits>

#include <mt/mt.hpp>

static_assert(std::is_class_v<mt::Device>);
static_assert(std::is_class_v<mt::DeviceInfo>);

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}
