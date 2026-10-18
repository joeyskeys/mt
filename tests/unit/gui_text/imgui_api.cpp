#include <type_traits>

#include <mt/imgui.hpp>

static_assert(std::is_class_v<mt::ImGuiBackendConfiguration>);
static_assert(std::is_class_v<mt::ImGuiFrameInfo>);
static_assert(std::is_class_v<mt::ImGuiDrawDataSummary>);
static_assert(std::is_class_v<mt::ImGuiInputEvent>);
static_assert(std::is_class_v<mt::ImGuiInputTranslator>);
static_assert(std::is_class_v<mt::ImGuiBackend>);

int main() {
    return 0;
}
