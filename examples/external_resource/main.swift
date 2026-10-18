import MTCore
import MTExternalResources

let descriptor = IOSurfaceTextureDescriptor(
    surfaceID: 1,
    width: 1920,
    height: 1080,
    pixelFormat: .bgra8Unorm,
    plane: 0,
    usage: UInt32(TextureUsage.shaderRead.rawValue),
    ownership: .borrowed,
    label: "producer-owned video frame"
)

let importer = IOSurfaceResourceImporter()
let diagnostics = importer.validate(descriptor)
if diagnostics.isEmpty {
    print(
        "The descriptor is structurally valid; the producer must supply "
        + "the IOSurface before import."
    )
} else {
    for diagnostic in diagnostics {
        print("\(diagnostic.code): \(diagnostic.message)")
    }
}

let synchronization = ExternalEventSyncPolicy(
    waitValue: 11,
    signalValue: 12,
    waitBeforeEncoding: true,
    signalAfterEncoding: true
)
print("shared-event policy valid: \(synchronization.isValid)")
