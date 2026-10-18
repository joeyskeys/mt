#pragma once

#include <mt/swift_api.hpp>
#include <MTExternalResources-Swift.h>

namespace mt {

using ExternalResourceOwnership =
    MTExternalResources::ExternalResourceOwnership;
using ExternalResourceDiagnosticCode =
    MTExternalResources::ExternalResourceDiagnosticCode;
using ExternalResourceDiagnostic =
    MTExternalResources::ExternalResourceDiagnostic;
using IOSurfaceTextureDescriptor =
    MTExternalResources::IOSurfaceTextureDescriptor;
using IOSurfaceBufferDescriptor =
    MTExternalResources::IOSurfaceBufferDescriptor;
using ExternalEventSyncPolicy =
    MTExternalResources::ExternalEventSyncPolicy;
using ExternalTextureImportResult =
    MTExternalResources::ExternalTextureImportResult;
using ExternalBufferImportResult =
    MTExternalResources::ExternalBufferImportResult;
using ImportedExternalTexture =
    MTExternalResources::ImportedExternalTexture;
using ImportedExternalBuffer =
    MTExternalResources::ImportedExternalBuffer;
using IOSurfaceResourceImporter =
    MTExternalResources::IOSurfaceResourceImporter;
using ExternalSharedEventBridge =
    MTExternalResources::ExternalSharedEventBridge;

} // namespace mt
