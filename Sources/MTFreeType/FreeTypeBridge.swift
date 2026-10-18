import Foundation
import MTCore
import MTText

/// A value-only rasterized glyph packet.
///
/// A consumer may fill this from an application-owned FreeType `FT_GlyphSlot`
/// without exposing `FT_Face`, FreeType allocators, or FreeType headers to
/// this target.
public struct FreeTypeGlyphBitmap {
    public var codePoint: UInt32
    public var width: UInt32
    public var height: UInt32
    public var bearingX: Double
    public var bearingY: Double
    public var advanceX: Double
    public var pixels: [UInt8]

    public init(
        codePoint: UInt32,
        width: UInt32,
        height: UInt32,
        bearingX: Double,
        bearingY: Double,
        advanceX: Double,
        pixels: [UInt8]
    ) {
        self.codePoint = codePoint
        self.width = width
        self.height = height
        self.bearingX = bearingX
        self.bearingY = bearingY
        self.advanceX = advanceX
        self.pixels = pixels
    }

    public var isValid: Bool {
        width > 0
            && height > 0
            && UInt64(width) * UInt64(height) == UInt64(pixels.count)
            && bearingX.isFinite
            && bearingY.isFinite
            && advanceX.isFinite
    }
}

/// Builds the same atlas/mesh value contract as the CoreText backend without
/// linking or owning FreeType.
public final class FreeTypeTextBridge {
    public init() {}

    public func makeAtlas(
        glyphs: [FreeTypeGlyphBitmap],
        padding: UInt32 = 1,
        maxWidth: UInt32 = 1024
    ) -> TextAtlas? {
        guard maxWidth > 0 else {
            return nil
        }

        struct PackedGlyph {
            var glyph: FreeTypeGlyphBitmap
            var x: UInt32
            var y: UInt32
        }

        var packed: [PackedGlyph] = []
        var seen = Set<UInt32>()
        var cursorX = padding
        var cursorY = padding
        var rowHeight = UInt32(0)
        for glyph in glyphs
        where glyph.isValid && seen.insert(glyph.codePoint).inserted {
            let paddedWidth = glyph.width + padding * 2
            let paddedHeight = glyph.height + padding * 2
            guard paddedWidth <= maxWidth else {
                continue
            }
            if cursorX > padding,
               cursorX + paddedWidth > maxWidth {
                cursorX = padding
                cursorY += rowHeight
                rowHeight = 0
            }
            packed.append(
                PackedGlyph(
                    glyph: glyph,
                    x: cursorX + padding,
                    y: cursorY + padding
                )
            )
            cursorX += paddedWidth
            rowHeight = max(rowHeight, paddedHeight)
        }
        guard !packed.isEmpty else {
            return nil
        }

        let atlasHeight = cursorY + rowHeight
        let pixelCount = UInt64(maxWidth) * UInt64(atlasHeight)
        guard atlasHeight > 0, pixelCount <= UInt64(Int.max) else {
            return nil
        }
        var pixels = [UInt8](repeating: 0, count: Int(pixelCount))
        var regions: [TextAtlasRegion] = []
        for item in packed {
            let sourceRowBytes = Int(item.glyph.width)
            for row in 0..<Int(item.glyph.height) {
                let sourceStart = row * sourceRowBytes
                let destinationStart =
                    (Int(item.y) + row) * Int(maxWidth) + Int(item.x)
                let source = item.glyph.pixels[
                    sourceStart..<(sourceStart + sourceRowBytes)
                ]
                pixels.replaceSubrange(
                    destinationStart..<(destinationStart + sourceRowBytes),
                    with: source
                )
            }
            regions.append(
                TextAtlasRegion(
                    codePoint: item.glyph.codePoint,
                    x: item.x,
                    y: item.y,
                    width: item.glyph.width,
                    height: item.glyph.height,
                    bearingX: item.glyph.bearingX,
                    bearingY: item.glyph.bearingY,
                    advanceX: item.glyph.advanceX
                )
            )
        }
        return TextAtlas(
            width: maxWidth,
            height: atlasHeight,
            pixels: pixels,
            regions: regions
        )
    }

    public func makeMesh(
        layout: TextLayout,
        atlas: TextAtlas,
        color: Vector4
    ) -> TextMesh {
        TextMeshBuilder.makeMesh(
            layout: layout,
            atlas: atlas,
            color: color
        )
    }
}
