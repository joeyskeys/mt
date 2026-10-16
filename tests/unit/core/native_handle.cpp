#include <cassert>

#include <mt/native_handle.hpp>

int main() {
    int marker = 0;

    const mt::NativeHandle empty;
    assert(!empty);
    assert(empty.type() == mt::NativeHandleType::none);

    const auto borrowed = mt::NativeHandle::borrowed(
        &marker,
        mt::NativeHandleType::metal_resource);

    assert(borrowed);
    assert(borrowed.type() == mt::NativeHandleType::metal_resource);
    assert(borrowed.value() == &marker);
    assert(borrowed.as<int>() == &marker);

    return 0;
}

