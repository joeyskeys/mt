import MTCore
import MTText
import XCTest

final class CoreTextIntegrationTests: XCTestCase {
    private func makeFont() throws -> CoreTextFont {
        guard let font = CoreTextFont(
            familyName: "Helvetica",
            pointSize: 18
        ) else {
            throw XCTSkip("Helvetica is unavailable on this machine.")
        }
        return font
    }

    func testCoreTextMetricsAndGlyphLookup() throws {
        let font = try makeFont()
        XCTAssertGreaterThan(font.metrics.lineHeight, 0)
        let glyph = font.glyph(codePoint: 65)
        XCTAssertNotNil(glyph)
        XCTAssertEqual(glyph?.codePoint, 65)
        XCTAssertGreaterThan(glyph?.advance.x ?? 0, 0)
    }

    func testAtlasLayoutAndMeshAreDeterministicValueContracts() throws {
        let font = try makeFont()
        let codePoints = Array("ABあ".unicodeScalars).map(\.value)
        guard let atlas = font.makeAtlas(
            codePoints: codePoints,
            padding: 1,
            maxWidth: 256
        ) else {
            XCTFail("The CoreText atlas could not be created.")
            return
        }
        XCTAssertTrue(atlas.isValid)
        let supportedCodePoints = codePoints.filter {
            font.glyph(codePoint: $0) != nil
        }
        XCTAssertEqual(
            atlas.regions.map(\.codePoint),
            supportedCodePoints
        )

        let layout = font.layout(
            text: "ABあ",
            origin: Vector2(x: 0, y: 24),
            maxWidth: 256,
            lineSpacing: 2
        )
        let mesh = font.makeMesh(
            layout: layout,
            atlas: atlas,
            color: Vector4(x: 1, y: 0.5, z: 0.25, w: 1)
        )
        XCTAssertTrue(layout.isValid)
        XCTAssertTrue(mesh.isValid)
        XCTAssertEqual(
            mesh.indexCount,
            UInt32(supportedCodePoints.count * 6)
        )
    }

    func testTextResourcesCanUseTheCoreDeviceLifetime() throws {
        let font = try makeFont()
        guard let atlas = font.makeAtlas(
            codePoints: [65, 66, 67],
            padding: 1,
            maxWidth: 128
        ) else {
            XCTFail("The CoreText atlas could not be created.")
            return
        }
        let layout = font.layout(
            text: "ABC",
            origin: Vector2(x: 0, y: 24),
            maxWidth: 128,
            lineSpacing: 0
        )
        let mesh = font.makeMesh(
            layout: layout,
            atlas: atlas,
            color: Vector4(x: 1, y: 1, z: 1, w: 1)
        )
        guard let device = Device.systemDefault() else {
            throw XCTSkip("No Metal device is available on this machine.")
        }
        guard let texture = atlas.uploadTexture(device: device),
              let sampler = TextSamplerPolicy.linearClamp.makeSampler(
                  device: device
              ),
              let gpuMesh = TextMeshGPU.upload(mesh: mesh, device: device)
        else {
            XCTFail("The text resources could not be uploaded.")
            return
        }
        XCTAssertTrue(texture.isCPUVisible)
        XCTAssertTrue(texture.isShared)
        XCTAssertNotNil(sampler)
        XCTAssertEqual(gpuMesh.indexCount, mesh.indexCount)
    }
}
