import CoreGraphics
import CoreText
import Foundation
import MTCore

public struct TextFontMetrics {
    public var ascent: Double
    public var descent: Double
    public var leading: Double
    public var lineHeight: Double
    public var capHeight: Double
    public var xHeight: Double

    public init(
        ascent: Double,
        descent: Double,
        leading: Double,
        lineHeight: Double,
        capHeight: Double,
        xHeight: Double
    ) {
        self.ascent = ascent
        self.descent = descent
        self.leading = leading
        self.lineHeight = lineHeight
        self.capHeight = capHeight
        self.xHeight = xHeight
    }
}

public struct TextGlyph {
    public var codePoint: UInt32
    public var glyphID: UInt32
    public var advance: Vector2
    public var boundsX: Double
    public var boundsY: Double
    public var boundsWidth: Double
    public var boundsHeight: Double

    public init(
        codePoint: UInt32,
        glyphID: UInt32,
        advance: Vector2,
        boundsX: Double,
        boundsY: Double,
        boundsWidth: Double,
        boundsHeight: Double
    ) {
        self.codePoint = codePoint
        self.glyphID = glyphID
        self.advance = advance
        self.boundsX = boundsX
        self.boundsY = boundsY
        self.boundsWidth = boundsWidth
        self.boundsHeight = boundsHeight
    }
}

public struct TextAtlasRegion {
    public var codePoint: UInt32
    public var x: UInt32
    public var y: UInt32
    public var width: UInt32
    public var height: UInt32
    public var bearingX: Double
    public var bearingY: Double
    public var advanceX: Double

    public init(
        codePoint: UInt32,
        x: UInt32,
        y: UInt32,
        width: UInt32,
        height: UInt32,
        bearingX: Double,
        bearingY: Double,
        advanceX: Double
    ) {
        self.codePoint = codePoint
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.bearingX = bearingX
        self.bearingY = bearingY
        self.advanceX = advanceX
    }
}

public struct TextAtlas {
    public var width: UInt32
    public var height: UInt32
    public var pixels: [UInt8]
    public var regions: [TextAtlasRegion]

    public init(
        width: UInt32,
        height: UInt32,
        pixels: [UInt8],
        regions: [TextAtlasRegion]
    ) {
        self.width = width
        self.height = height
        self.pixels = pixels
        self.regions = regions
    }

    public var isValid: Bool {
        width > 0
            && height > 0
            && UInt64(width) * UInt64(height) == UInt64(pixels.count)
    }

    public func region(for codePoint: UInt32) -> TextAtlasRegion? {
        regions.first { $0.codePoint == codePoint }
    }

    public func uploadTexture(
        device: Device,
        storageMode: StorageMode = .shared,
        label: String = "mt text atlas"
    ) -> Texture? {
        guard isValid else {
            return nil
        }
        guard let texture = device.createTexture(
            TextureDescriptor(
                textureType: .twoD,
                pixelFormat: .r8Unorm,
                width: width,
                height: height,
                depth: 1,
                arrayLength: 1,
                mipLevelCount: 1,
                sampleCount: 1,
                usage: UInt32(TextureUsage.shaderRead.rawValue),
                storageMode: storageMode,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: label
            )
        ) else {
            return nil
        }
        let didUpload = pixels.withUnsafeBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return false
            }
            return texture.replaceBaseLevel2D(
                source: baseAddress,
                bytesPerRow: UInt64(width),
                bytesPerImage: UInt64(pixels.count)
            )
        }
        return didUpload ? texture : nil
    }
}

public struct TextSamplerPolicy {
    public var minFilter: SamplerFilter
    public var magFilter: SamplerFilter
    public var addressMode: SamplerAddressMode

    public init(
        minFilter: SamplerFilter,
        magFilter: SamplerFilter,
        addressMode: SamplerAddressMode
    ) {
        self.minFilter = minFilter
        self.magFilter = magFilter
        self.addressMode = addressMode
    }

    public static var linearClamp: TextSamplerPolicy {
        TextSamplerPolicy(
            minFilter: .linear,
            magFilter: .linear,
            addressMode: .clampToEdge
        )
    }

    public func makeSampler(
        device: Device,
        label: String = "mt text sampler"
    ) -> Sampler? {
        device.createSampler(
            SamplerDescriptor(
                minFilter: minFilter,
                magFilter: magFilter,
                mipFilter: .notMipmapped,
                addressModeS: addressMode,
                addressModeT: addressMode,
                addressModeR: addressMode,
                compareFunction: .always,
                maxAnisotropy: 1,
                lodMinClamp: 0,
                lodMaxClamp: 0,
                label: label
            )
        )
    }
}

public struct TextGlyphPlacement {
    public var codePoint: UInt32
    public var glyphID: UInt32
    public var baselinePosition: Vector2
    public var advance: Vector2

    public init(
        codePoint: UInt32,
        glyphID: UInt32,
        baselinePosition: Vector2,
        advance: Vector2
    ) {
        self.codePoint = codePoint
        self.glyphID = glyphID
        self.baselinePosition = baselinePosition
        self.advance = advance
    }
}

public struct TextLayout {
    public var width: Double
    public var height: Double
    public var placements: [TextGlyphPlacement]

    public init(
        width: Double,
        height: Double,
        placements: [TextGlyphPlacement]
    ) {
        self.width = width
        self.height = height
        self.placements = placements
    }

    public var isValid: Bool {
        width >= 0 && height >= 0
    }
}

public struct TextVertex {
    public var position: Vector2
    public var texCoord: Vector2
    public var color: Vector4

    public init(
        position: Vector2,
        texCoord: Vector2,
        color: Vector4
    ) {
        self.position = position
        self.texCoord = texCoord
        self.color = color
    }
}

public struct TextMesh {
    public var vertices: [TextVertex]
    public var indices: [UInt32]

    public init(vertices: [TextVertex], indices: [UInt32]) {
        self.vertices = vertices
        self.indices = indices
    }

    public var isValid: Bool {
        !vertices.isEmpty
            && !indices.isEmpty
            && indices.count % 3 == 0
            && indices.allSatisfy { Int($0) < vertices.count }
    }

    public var indexCount: UInt32 {
        UInt32(min(indices.count, Int(UInt32.max)))
    }
}

public final class TextMeshGPU {
    public let vertexBuffer: Buffer
    public let indexBuffer: Buffer
    public let indexCount: UInt32

    private init(
        vertexBuffer: Buffer,
        indexBuffer: Buffer,
        indexCount: UInt32
    ) {
        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
    }

    public static func upload(
        mesh: TextMesh,
        device: Device,
        label: String = "mt text mesh"
    ) -> TextMeshGPU? {
        guard mesh.isValid else {
            return nil
        }
        let vertexLength = UInt64(
            mesh.vertices.count * MemoryLayout<TextVertex>.stride
        )
        let indexLength = UInt64(
            mesh.indices.count * MemoryLayout<UInt32>.stride
        )
        guard let vertexBuffer = device.createBuffer(
            BufferDescriptor(
                length: vertexLength,
                usage: UInt32(BufferUsage.vertex.rawValue),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: label + " vertices"
            )
        ),
        let indexBuffer = device.createBuffer(
            BufferDescriptor(
                length: indexLength,
                usage: UInt32(BufferUsage.index.rawValue),
                storageMode: .shared,
                cpuCacheMode: .defaultCache,
                hazardMode: .defaultMode,
                label: label + " indices"
            )
        ) else {
            return nil
        }

        let didUploadVertices = mesh.vertices.withUnsafeBufferPointer {
            pointer in
            guard let baseAddress = pointer.baseAddress else {
                return false
            }
            return vertexBuffer.upload(
                source: UnsafeRawPointer(baseAddress),
                length: vertexLength,
                offset: 0
            )
        }
        let didUploadIndices = mesh.indices.withUnsafeBufferPointer {
            pointer in
            guard let baseAddress = pointer.baseAddress else {
                return false
            }
            return indexBuffer.upload(
                source: UnsafeRawPointer(baseAddress),
                length: indexLength,
                offset: 0
            )
        }
        guard didUploadVertices, didUploadIndices else {
            return nil
        }
        return TextMeshGPU(
            vertexBuffer: vertexBuffer,
            indexBuffer: indexBuffer,
            indexCount: mesh.indexCount
        )
    }
}

public final class TextMeshBuilder {
    private init() {}

    public static func makeMesh(
        layout: TextLayout,
        atlas: TextAtlas,
        color: Vector4
    ) -> TextMesh {
        guard layout.isValid, atlas.isValid else {
            return TextMesh(vertices: [], indices: [])
        }
        var vertices: [TextVertex] = []
        var indices: [UInt32] = []
        for placement in layout.placements {
            guard let region = atlas.region(for: placement.codePoint) else {
                continue
            }
            let originX = Double(placement.baselinePosition.x)
                + region.bearingX
            let originY = Double(placement.baselinePosition.y)
                + region.bearingY
            let x0 = Float(originX)
            let y0 = Float(originY)
            let x1 = x0 + Float(region.width)
            let y1 = y0 + Float(region.height)
            let u0 = Float(region.x) / Float(atlas.width)
            let v0 = Float(region.y) / Float(atlas.height)
            let u1 = Float(region.x + region.width)
                / Float(atlas.width)
            let v1 = Float(region.y + region.height)
                / Float(atlas.height)
            let base = UInt32(vertices.count)
            vertices.append(
                TextVertex(
                    position: Vector2(x: x0, y: y0),
                    texCoord: Vector2(x: u0, y: v0),
                    color: color
                )
            )
            vertices.append(
                TextVertex(
                    position: Vector2(x: x1, y: y0),
                    texCoord: Vector2(x: u1, y: v0),
                    color: color
                )
            )
            vertices.append(
                TextVertex(
                    position: Vector2(x: x1, y: y1),
                    texCoord: Vector2(x: u1, y: v1),
                    color: color
                )
            )
            vertices.append(
                TextVertex(
                    position: Vector2(x: x0, y: y1),
                    texCoord: Vector2(x: u0, y: v1),
                    color: color
                )
            )
            indices.append(contentsOf: [
                base,
                base + 1,
                base + 2,
                base,
                base + 2,
                base + 3
            ])
        }
        return TextMesh(vertices: vertices, indices: indices)
    }
}

public final class CoreTextFont {
    private let nativeFont: CTFont
    public let familyName: String
    public let pointSize: Double
    public let metrics: TextFontMetrics

    public init?(familyName: String, pointSize: Double) {
        guard !familyName.isEmpty, pointSize.isFinite, pointSize > 0 else {
            return nil
        }
        let font = CTFontCreateWithName(
            familyName as CFString,
            CGFloat(pointSize),
            nil
        )
        self.nativeFont = font
        self.familyName = familyName
        self.pointSize = pointSize
        let ascent = Double(CTFontGetAscent(font))
        let descent = Double(CTFontGetDescent(font))
        let leading = Double(CTFontGetLeading(font))
        self.metrics = TextFontMetrics(
            ascent: ascent,
            descent: descent,
            leading: leading,
            lineHeight: max(1, ascent + descent + leading),
            capHeight: Double(CTFontGetCapHeight(font)),
            xHeight: Double(CTFontGetXHeight(font))
        )
    }

    public func glyph(codePoint: UInt32) -> TextGlyph? {
        guard let scalar = UnicodeScalar(codePoint) else {
            return nil
        }
        var characters = Array(String(scalar).utf16)
        guard !characters.isEmpty else {
            return nil
        }
        var glyphID: CGGlyph = 0
        let found = characters.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return false
            }
            return CTFontGetGlyphsForCharacters(
                nativeFont,
                baseAddress,
                &glyphID,
                1
            )
        }
        guard found, glyphID != 0 else {
            return nil
        }
        var glyph = glyphID
        var advance = CGSize.zero
        _ = CTFontGetAdvancesForGlyphs(
            nativeFont,
            .horizontal,
            &glyph,
            &advance,
            1
        )
        var bounds = CGRect.zero
        _ = CTFontGetBoundingRectsForGlyphs(
            nativeFont,
            .horizontal,
            &glyph,
            &bounds,
            1
        )
        return TextGlyph(
            codePoint: codePoint,
            glyphID: UInt32(glyphID),
            advance: Vector2(
                x: Float(advance.width),
                y: Float(advance.height)
            ),
            boundsX: Double(bounds.origin.x),
            boundsY: Double(bounds.origin.y),
            boundsWidth: Double(bounds.width),
            boundsHeight: Double(bounds.height)
        )
    }

    public func layout(
        text: String,
        origin: Vector2,
        maxWidth: Double,
        lineSpacing: Double
    ) -> TextLayout {
        var placements: [TextGlyphPlacement] = []
        var cursorX = Double(origin.x)
        var baselineY = Double(origin.y)
        var maximumX = cursorX
        let lineHeight = metrics.lineHeight + max(0, lineSpacing)
        var lineCount = 1

        for scalar in text.unicodeScalars {
            if scalar.value == 10 {
                baselineY -= lineHeight
                cursorX = Double(origin.x)
                lineCount += 1
                continue
            }
            guard let glyph = glyph(codePoint: scalar.value) else {
                continue
            }
            let advance = Double(glyph.advance.x)
            if maxWidth > 0,
               cursorX > Double(origin.x),
               cursorX + advance > Double(origin.x) + maxWidth {
                baselineY -= lineHeight
                cursorX = Double(origin.x)
                lineCount += 1
            }
            placements.append(
                TextGlyphPlacement(
                    codePoint: scalar.value,
                    glyphID: glyph.glyphID,
                    baselinePosition: Vector2(
                        x: Float(cursorX),
                        y: Float(baselineY)
                    ),
                    advance: glyph.advance
                )
            )
            cursorX += advance
            maximumX = max(maximumX, cursorX)
        }

        return TextLayout(
            width: max(0, maximumX - Double(origin.x)),
            height: Double(lineCount) * lineHeight,
            placements: placements
        )
    }

    public func makeAtlas(
        codePoints: [UInt32],
        padding: UInt32 = 1,
        maxWidth: UInt32 = 1024
    ) -> TextAtlas? {
        guard maxWidth > 0 else {
            return nil
        }
        var glyphs: [TextGlyph] = []
        var seen = Set<UInt32>()
        for codePoint in codePoints where seen.insert(codePoint).inserted {
            if let glyph = glyph(codePoint: codePoint) {
                glyphs.append(glyph)
            }
        }
        guard !glyphs.isEmpty else {
            return nil
        }

        struct PackedGlyph {
            var glyph: TextGlyph
            var x: UInt32
            var y: UInt32
            var width: UInt32
            var height: UInt32
        }
        var packed: [PackedGlyph] = []
        var cursorX = padding
        var cursorY = padding
        var rowHeight = UInt32(0)
        for glyph in glyphs {
            let width = UInt32(
                max(1, Int(ceil(glyph.boundsWidth)))
            ) + padding * 2
            let height = UInt32(
                max(1, Int(ceil(glyph.boundsHeight)))
            ) + padding * 2
            if cursorX > padding, cursorX + width > maxWidth {
                cursorX = padding
                cursorY += rowHeight
                rowHeight = 0
            }
            guard width <= maxWidth else {
                continue
            }
            packed.append(
                PackedGlyph(
                    glyph: glyph,
                    x: cursorX + padding,
                    y: cursorY + padding,
                    width: width - padding * 2,
                    height: height - padding * 2
                )
            )
            cursorX += width
            rowHeight = max(rowHeight, height)
        }
        guard !packed.isEmpty else {
            return nil
        }
        let atlasHeight = cursorY + rowHeight
        let pixelCount = UInt64(maxWidth) * UInt64(atlasHeight)
        guard atlasHeight > 0,
              pixelCount <= UInt64(Int.max)
        else {
            return nil
        }

        var pixels = [UInt8](repeating: 0, count: Int(pixelCount))
        let colorSpace = CGColorSpaceCreateDeviceGray()
        pixels.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress,
                  let context = CGContext(
                      data: baseAddress,
                      width: Int(maxWidth),
                      height: Int(atlasHeight),
                      bitsPerComponent: 8,
                      bytesPerRow: Int(maxWidth),
                      space: colorSpace,
                      bitmapInfo: CGImageAlphaInfo.none.rawValue
                  ) else {
                return
            }
            context.setFillColor(gray: 1, alpha: 1)
            for item in packed {
                var glyph = CGGlyph(item.glyph.glyphID)
                let bounds = CGRect(
                    x: item.glyph.boundsX,
                    y: item.glyph.boundsY,
                    width: item.glyph.boundsWidth,
                    height: item.glyph.boundsHeight
                )
                var position = CGPoint(
                    x: CGFloat(Double(item.x) - bounds.origin.x),
                    y: CGFloat(Double(item.y) - bounds.origin.y)
                )
                CTFontDrawGlyphs(
                    nativeFont,
                    &glyph,
                    &position,
                    1,
                    context
                )
            }
        }

        let regions = packed.map { item in
            TextAtlasRegion(
                codePoint: item.glyph.codePoint,
                x: item.x,
                y: item.y,
                width: item.width,
                height: item.height,
                bearingX: item.glyph.boundsX,
                bearingY: item.glyph.boundsY,
                advanceX: Double(item.glyph.advance.x)
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
