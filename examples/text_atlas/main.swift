import Foundation
import MTCore
import MTText

if let font = CoreTextFont(familyName: "Helvetica", pointSize: 18) {
    let codePoints = Array("mt Metal text".unicodeScalars).map(\.value)
    if let atlas = font.makeAtlas(
        codePoints: codePoints,
        padding: 2,
        maxWidth: 512
    ) {
        let layout = font.layout(
            text: "mt Metal text",
            origin: Vector2(x: 0, y: 24),
            maxWidth: 512,
            lineSpacing: 2
        )
        let mesh = font.makeMesh(
            layout: layout,
            atlas: atlas,
            color: Vector4(x: 1, y: 1, z: 1, w: 1)
        )
        print(
            "font=\(font.familyName) atlas=\(atlas.width)x\(atlas.height) "
                + "glyphs=\(atlas.regions.count) indices=\(mesh.indexCount)"
        )
    } else {
        print("Could not build the CoreText atlas")
    }
} else {
    print("CoreText font unavailable")
}
