#include <type_traits>

#include <mt/freetype.hpp>

static_assert(std::is_class_v<mt::FreeTypeGlyphBitmap>);
static_assert(std::is_class_v<mt::FreeTypeTextBridge>);

int main() {
    return 0;
}
