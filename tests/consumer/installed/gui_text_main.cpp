#include <type_traits>

#include <mt/mt.hpp>

#if defined(MT_INSTALLED_HAS_IMGUI)
#include <mt/imgui.hpp>
#endif

#if defined(MT_INSTALLED_HAS_TEXT)
#include <mt/text.hpp>
#endif

#if defined(MT_INSTALLED_HAS_FREETYPE)
#include <mt/freetype.hpp>
#endif

static_assert(std::is_class_v<mt::Device>);

#if defined(MT_INSTALLED_HAS_IMGUI)
static_assert(std::is_class_v<mt::ImGuiBackend>);
static_assert(std::is_class_v<mt::ImGuiInputTranslator>);
#endif

#if defined(MT_INSTALLED_HAS_TEXT)
static_assert(std::is_class_v<mt::CoreTextFont>);
static_assert(std::is_class_v<mt::TextMeshGPU>);
#endif

#if defined(MT_INSTALLED_HAS_FREETYPE)
static_assert(std::is_class_v<mt::FreeTypeGlyphBitmap>);
static_assert(std::is_class_v<mt::FreeTypeTextBridge>);
#endif

int main() {
    return mt::library_version() == nullptr ? 1 : 0;
}
