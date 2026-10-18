#pragma once

#include <mt/swift_api.hpp>
#include <MTAssetPipeline-Swift.h>

namespace mt {

using AssetDiagnosticSeverity = MTAssetPipeline::AssetDiagnosticSeverity;
using AssetDiagnosticCode = MTAssetPipeline::AssetDiagnosticCode;
using AssetDiagnostic = MTAssetPipeline::AssetDiagnostic;
using AssetDiagnosticReport = MTAssetPipeline::AssetDiagnosticReport;
using AssetAxis = MTAssetPipeline::AssetAxis;
using AssetHandedness = MTAssetPipeline::AssetHandedness;
using AssetWindingPolicy = MTAssetPipeline::AssetWindingPolicy;
using AssetColorSpace = MTAssetPipeline::AssetColorSpace;
using AssetTextureOrigin = MTAssetPipeline::AssetTextureOrigin;
using AssetTextureFormatPolicy =
    MTAssetPipeline::AssetTextureFormatPolicy;
using AssetTexturePixelFormat =
    MTAssetPipeline::AssetTexturePixelFormat;
using AssetMipPolicy = MTAssetPipeline::AssetMipPolicy;
using AssetPrimitiveType = MTAssetPipeline::AssetPrimitiveType;
using AssetAlphaMode = MTAssetPipeline::AssetAlphaMode;
using AssetTextureSemantic = MTAssetPipeline::AssetTextureSemantic;
using AssetVector2 = MTAssetPipeline::AssetVector2;
using AssetVector3 = MTAssetPipeline::AssetVector3;
using AssetVector4 = MTAssetPipeline::AssetVector4;
using AssetCoordinateSystem =
    MTAssetPipeline::AssetCoordinateSystem;
using AssetConversionPolicy = MTAssetPipeline::AssetConversionPolicy;
using AssetSourceMetadata = MTAssetPipeline::AssetSourceMetadata;
using AssetVertex = MTAssetPipeline::AssetVertex;
using AssetLODLevel = MTAssetPipeline::AssetLODLevel;
using AssetCullingMetadata = MTAssetPipeline::AssetCullingMetadata;
using AssetMeshletDescriptor =
    MTAssetPipeline::AssetMeshletDescriptor;
using AssetMesh = MTAssetPipeline::AssetMesh;
using AssetMeshConversionResult =
    MTAssetPipeline::AssetMeshConversionResult;
using AssetTextureLevel = MTAssetPipeline::AssetTextureLevel;
using AssetTexture = MTAssetPipeline::AssetTexture;
using AssetTextureConversionResult =
    MTAssetPipeline::AssetTextureConversionResult;
using AssetTextureLoadResult =
    MTAssetPipeline::AssetTextureLoadResult;
using AssetTextureReference =
    MTAssetPipeline::AssetTextureReference;
using AssetMaterial = MTAssetPipeline::AssetMaterial;
using AssetMaterialConversionResult =
    MTAssetPipeline::AssetMaterialConversionResult;
using AssetCurveInterpolation =
    MTAssetPipeline::AssetCurveInterpolation;
using AssetCurvePoint = MTAssetPipeline::AssetCurvePoint;
using AssetCurve = MTAssetPipeline::AssetCurve;
using AssetTransform = MTAssetPipeline::AssetTransform;
using AssetNode = MTAssetPipeline::AssetNode;
using AssetDocument = MTAssetPipeline::AssetDocument;
using AssetImportResult = MTAssetPipeline::AssetImportResult;
using AssetDocumentConversionResult =
    MTAssetPipeline::AssetDocumentConversionResult;
using AssetImporterAdapter = MTAssetPipeline::AssetImporterAdapter;
using AssetPipeline = MTAssetPipeline::AssetPipeline;
using AssetTextureLoader = MTAssetPipeline::AssetTextureLoader;
using AssetSerializer = MTAssetPipeline::AssetSerializer;
using AssetSerializationResult =
    MTAssetPipeline::AssetSerializationResult;
using AssetColorConverter = MTAssetPipeline::AssetColorConverter;

} // namespace mt
