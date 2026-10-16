#include <mt/mt.hpp>

int main() {
    const auto version = mt::library_version();
    return version != nullptr && version[0] != '\0' ? 0 : 1;
}

