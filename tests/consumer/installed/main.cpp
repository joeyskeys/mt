#include <mt/mt.hpp>

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}

