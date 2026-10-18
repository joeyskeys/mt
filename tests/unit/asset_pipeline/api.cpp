#include <type_traits>

#include <mt/asset_pipeline.hpp>

static_assert(std::is_class_v<mt::AssetDiagnostic>);
static_assert(std::is_class_v<mt::AssetDiagnosticReport>);
static_assert(std::is_class_v<mt::AssetCoordinateSystem>);
static_assert(std::is_class_v<mt::AssetConversionPolicy>);
static_assert(std::is_class_v<mt::AssetVertex>);
static_assert(std::is_class_v<mt::AssetMesh>);
static_assert(std::is_class_v<mt::AssetTexture>);
static_assert(std::is_class_v<mt::AssetMaterial>);
static_assert(std::is_class_v<mt::AssetDocument>);
static_assert(std::is_class_v<mt::AssetImporterAdapter>);
static_assert(std::is_class_v<mt::AssetPipeline>);
static_assert(std::is_class_v<mt::AssetSerializer>);

int main() {
    return 0;
}
