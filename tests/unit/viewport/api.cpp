#include <type_traits>

#include <mt/input.hpp>
#include <mt/picking.hpp>
#include <mt/viewport.hpp>

static_assert(std::is_class_v<mt::ViewportCamera>);
static_assert(std::is_class_v<mt::ViewportUpdate>);
static_assert(std::is_class_v<mt::ViewportFeature>);
static_assert(std::is_class_v<mt::ViewportAccelerationSelection>);
static_assert(std::is_class_v<mt::ViewportPickingConfiguration>);
static_assert(std::is_class_v<mt::ViewportFeatureVertex>);
static_assert(std::is_class_v<mt::ViewportFeatureExtension>);
static_assert(std::is_class_v<mt::ViewportVertexCandidate>);
static_assert(std::is_class_v<mt::ViewportVertexSelectionResult>);
static_assert(std::is_class_v<mt::PickingID>);
static_assert(std::is_class_v<mt::ViewportPickRequest>);
static_assert(std::is_class_v<mt::ViewportPickResult>);
static_assert(std::is_class_v<mt::ViewportPickFrameData>);
static_assert(std::is_class_v<mt::Viewport>);
static_assert(std::is_class_v<mt::ViewportFixture>);
static_assert(std::is_class_v<mt::InputModifiers>);
static_assert(std::is_class_v<mt::HostInputEvent>);

int main() {
    return 0;
}

