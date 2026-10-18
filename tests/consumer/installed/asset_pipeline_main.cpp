#include <type_traits>

#include <mt/asset_pipeline.hpp>

#if !defined(MT_INSTALLED_HAS_ASSET_PIPELINE)
#error "The installed asset-pipeline target was not linked."
#endif

static_assert(std::is_class_v<mt::AssetDocument>);
static_assert(std::is_class_v<mt::AssetPipeline>);
static_assert(std::is_class_v<mt::AssetSerializer>);

int main() {
    return 0;
}
