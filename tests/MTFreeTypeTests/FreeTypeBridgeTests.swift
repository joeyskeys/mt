import MTCore
import MTFreeType
import MTText
import XCTest

final class FreeTypeBridgeTests: XCTestCase {
    private func glyph(
        codePoint: UInt32,
        value: UInt8
    ) -> FreeTypeGlyphBitmap {
        FreeTypeGlyphBitmap(
            codePoint: codePoint,
            width: 2,
            height: 2,
            bearingX: 0,
            bearingY: 0,
            advanceX: 2,
            pixels: [value, value, value, value]
        )
    }

    func testValueBridgeBuildsDeterministicAtlasWithoutFreeTypeOwnership() {
        let bridge = FreeTypeTextBridge()
        let atlas = bridge.makeAtlas(
            glyphs: [
                glyph(codePoint: 65, value: 17),
                glyph(codePoint: 66, value: 29)
            ],
            padding: 1,
            maxWidth: 16
        )
        XCTAssertNotNil(atlas)
        XCTAssertEqual(atlas?.regions.map(\.codePoint), [65, 66])
        XCTAssertTrue(atlas?.isValid ?? false)
    }

    func testBridgeSharesTextMeshContract() {
        let bridge = FreeTypeTextBridge()
        guard let atlas = bridge.makeAtlas(
            glyphs: [glyph(codePoint: 65, value: 255)],
            padding: 1,
            maxWidth: 8
        ) else {
            XCTFail("The FreeType value atlas could not be created.")
            return
        }
        let layout = TextLayout(
            width: 2,
            height: 2,
            placements: [
                TextGlyphPlacement(
                    codePoint: 65,
                    glyphID: 65,
                    baselinePosition: Vector2(x: 0, y: 2),
                    advance: Vector2(x: 2, y: 0)
                )
            ]
        )
        let mesh = bridge.makeMesh(
            layout: layout,
            atlas: atlas,
            color: Vector4(x: 1, y: 1, z: 1, w: 1)
        )
        XCTAssertTrue(mesh.isValid)
        XCTAssertEqual(mesh.indexCount, 6)
    }
}
