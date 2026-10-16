import Foundation
import Metal
import QuartzCore

public enum DeviceType: Int32 {
    case unknown
    case unified
    case integrated
    case discrete
    case external
}

public enum MetalFamily: Int32 {
    case unknown
    case mac1
    case mac2
    case apple1
    case apple2
    case apple3
    case apple4
    case apple5
    case apple6
    case apple7
}

public enum ArgumentBufferTier: Int32 {
    case unsupported
    case tier1
    case tier2
}

public enum DeviceFeature: Int32 {
    case argumentBuffers
    case argumentBufferTier2
    case indirectCommandBuffers
    case meshShaders
    case tileShaders
    case memorylessAttachments
    case rayTracing
    case dynamicLibraries
    case counterSampling
}

public enum CommandBufferStatus: Int32 {
    case notEnqueued
    case enqueued
    case committed
    case scheduled
    case completed
    case error
}

public enum PixelFormat: Int32 {
    case invalid
    case r8Unorm = 10
    case rg8Unorm = 30
    case rgba8Unorm = 70
    case rgba8UnormSrgb = 71
    case bgra8Unorm = 80
    case bgra8UnormSrgb = 81
    case r16Float = 110
    case rg16Float = 112
    case rgba16Float = 115
    case r32Float = 122
    case rg32Float = 123
    case rgba32Float = 124
    case depth16Unorm = 250
    case depth32Float = 252
    case stencil8 = 253
    case depth24UnormStencil8 = 255
    case depth32FloatStencil8 = 260
}

public enum TextureType: Int32 {
    case oneD
    case oneDArray
    case twoD
    case twoDArray
    case twoDMultisample
    case twoDMultisampleArray
    case threeD
    case cube
    case cubeArray
}

public enum StorageMode: Int32 {
    case shared
    case managed
    case gpuPrivate
    case memoryless
}

public enum CpuCacheMode: Int32 {
    case defaultCache
    case writeCombined
}

public enum HazardMode: Int32 {
    case defaultMode
    case untracked
    case tracked
}

public enum ResourceUsage: Int32 {
    case read = 1
    case write = 2
    case readWrite = 3
}

public enum SamplerFilter: Int32 {
    case nearest
    case linear
}

public enum SamplerMipFilter: Int32 {
    case notMipmapped
    case nearest
    case linear
}

public enum SamplerAddressMode: Int32 {
    case clampToEdge
    case mirrorClampToEdge
    case repeat
    case mirrorRepeat
    case clampToZero
}

public enum CompareFunction: Int32 {
    case never
    case less
    case equal
    case lessEqual
    case greater
    case notEqual
    case greaterEqual
    case always
}

public enum BufferUsage: Int32 {
    case none = 0
    case vertex = 1
    case index = 2
    case uniform = 4
    case storage = 8
    case indirect = 16
    case readback = 32
}

public enum TextureUsage: Int32 {
    case none = 0
    case shaderRead = 1
    case shaderWrite = 2
    case shaderAtomic = 8
    case renderTarget = 4
    case pixelFormatView = 16
}

public enum RenderLoadAction: Int32 {
    case dontCare
    case load
    case clear
}

public enum RenderStoreAction: Int32 {
    case dontCare
    case store
    case multisampleResolve
}

public struct Extent {
    public var width: UInt32
    public var height: UInt32

    public init(width: UInt32, height: UInt32) {
        self.width = width
        self.height = height
    }
}

public struct ClearColor {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(
        red: Double,
        green: Double,
        blue: Double,
        alpha: Double
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct BufferDescriptor {
    public var length: UInt64
    public var usage: UInt32
    public var storageMode: StorageMode
    public var cpuCacheMode: CpuCacheMode
    public var hazardMode: HazardMode
    public var label: String

    public init(
        length: UInt64,
        usage: UInt32,
        storageMode: StorageMode,
        cpuCacheMode: CpuCacheMode,
        hazardMode: HazardMode,
        label: String
    ) {
        self.length = length
        self.usage = usage
        self.storageMode = storageMode
        self.cpuCacheMode = cpuCacheMode
        self.hazardMode = hazardMode
        self.label = label
    }
}

public struct TextureDescriptor {
    public var textureType: TextureType
    public var pixelFormat: PixelFormat
    public var width: UInt32
    public var height: UInt32
    public var depth: UInt32
    public var arrayLength: UInt32
    public var mipLevelCount: UInt32
    public var sampleCount: UInt32
    public var usage: UInt32
    public var storageMode: StorageMode
    public var cpuCacheMode: CpuCacheMode
    public var hazardMode: HazardMode
    public var label: String

    public init(
        textureType: TextureType,
        pixelFormat: PixelFormat,
        width: UInt32,
        height: UInt32,
        depth: UInt32,
        arrayLength: UInt32,
        mipLevelCount: UInt32,
        sampleCount: UInt32,
        usage: UInt32,
        storageMode: StorageMode,
        cpuCacheMode: CpuCacheMode,
        hazardMode: HazardMode,
        label: String
    ) {
        self.textureType = textureType
        self.pixelFormat = pixelFormat
        self.width = width
        self.height = height
        self.depth = depth
        self.arrayLength = arrayLength
        self.mipLevelCount = mipLevelCount
        self.sampleCount = sampleCount
        self.usage = usage
        self.storageMode = storageMode
        self.cpuCacheMode = cpuCacheMode
        self.hazardMode = hazardMode
        self.label = label
    }
}

public struct SamplerDescriptor {
    public var minFilter: SamplerFilter
    public var magFilter: SamplerFilter
    public var mipFilter: SamplerMipFilter
    public var addressModeS: SamplerAddressMode
    public var addressModeT: SamplerAddressMode
    public var addressModeR: SamplerAddressMode
    public var compareFunction: CompareFunction
    public var maxAnisotropy: UInt16
    public var lodMinClamp: Double
    public var lodMaxClamp: Double
    public var label: String

    public init(
        minFilter: SamplerFilter,
        magFilter: SamplerFilter,
        mipFilter: SamplerMipFilter,
        addressModeS: SamplerAddressMode,
        addressModeT: SamplerAddressMode,
        addressModeR: SamplerAddressMode,
        compareFunction: CompareFunction,
        maxAnisotropy: UInt16,
        lodMinClamp: Double,
        lodMaxClamp: Double,
        label: String
    ) {
        self.minFilter = minFilter
        self.magFilter = magFilter
        self.mipFilter = mipFilter
        self.addressModeS = addressModeS
        self.addressModeT = addressModeT
        self.addressModeR = addressModeR
        self.compareFunction = compareFunction
        self.maxAnisotropy = maxAnisotropy
        self.lodMinClamp = lodMinClamp
        self.lodMaxClamp = lodMaxClamp
        self.label = label
    }
}

public struct HeapDescriptor {
    public var size: UInt64
    public var storageMode: StorageMode
    public var cpuCacheMode: CpuCacheMode
    public var hazardMode: HazardMode
    public var label: String

    public init(
        size: UInt64,
        storageMode: StorageMode,
        cpuCacheMode: CpuCacheMode,
        hazardMode: HazardMode,
        label: String
    ) {
        self.size = size
        self.storageMode = storageMode
        self.cpuCacheMode = cpuCacheMode
        self.hazardMode = hazardMode
        self.label = label
    }
}

fileprivate extension PixelFormat {
    var metalFormat: MTLPixelFormat {
        switch self {
        case .invalid:
            return .invalid
        case .r8Unorm:
            return .r8Unorm
        case .rg8Unorm:
            return .rg8Unorm
        case .rgba8Unorm:
            return .rgba8Unorm
        case .rgba8UnormSrgb:
            return .rgba8Unorm_sRGB
        case .bgra8Unorm:
            return .bgra8Unorm
        case .bgra8UnormSrgb:
            return .bgra8Unorm_sRGB
        case .r16Float:
            return .r16Float
        case .rg16Float:
            return .rg16Float
        case .rgba16Float:
            return .rgba16Float
        case .r32Float:
            return .r32Float
        case .rg32Float:
            return .rg32Float
        case .rgba32Float:
            return .rgba32Float
        case .depth16Unorm:
            return .depth16Unorm
        case .depth32Float:
            return .depth32Float
        case .stencil8:
            return .stencil8
        case .depth24UnormStencil8:
            return .depth24Unorm_Stencil8
        case .depth32FloatStencil8:
            return .depth32Float_Stencil8
        }
    }

    init(metalFormat: MTLPixelFormat) {
        switch metalFormat {
        case .r8Unorm:
            self = .r8Unorm
        case .rg8Unorm:
            self = .rg8Unorm
        case .rgba8Unorm:
            self = .rgba8Unorm
        case .rgba8Unorm_sRGB:
            self = .rgba8UnormSrgb
        case .bgra8Unorm:
            self = .bgra8Unorm
        case .bgra8Unorm_sRGB:
            self = .bgra8UnormSrgb
        case .r16Float:
            self = .r16Float
        case .rg16Float:
            self = .rg16Float
        case .rgba16Float:
            self = .rgba16Float
        case .r32Float:
            self = .r32Float
        case .rg32Float:
            self = .rg32Float
        case .rgba32Float:
            self = .rgba32Float
        case .depth16Unorm:
            self = .depth16Unorm
        case .depth32Float:
            self = .depth32Float
        case .stencil8:
            self = .stencil8
        case .depth24Unorm_Stencil8:
            self = .depth24UnormStencil8
        case .depth32Float_Stencil8:
            self = .depth32FloatStencil8
        default:
            self = .invalid
        }
    }

    var isColorFormat: Bool {
        switch self {
        case .r8Unorm, .rg8Unorm, .rgba8Unorm, .rgba8UnormSrgb,
             .bgra8Unorm, .bgra8UnormSrgb, .r16Float, .rg16Float,
             .rgba16Float, .r32Float, .rg32Float, .rgba32Float:
            return true
        case .invalid, .depth16Unorm, .depth32Float, .stencil8,
             .depth24UnormStencil8, .depth32FloatStencil8:
            return false
        }
    }

    var isDepthFormat: Bool {
        switch self {
        case .depth16Unorm, .depth32Float, .depth24UnormStencil8,
             .depth32FloatStencil8:
            return true
        case .invalid, .r8Unorm, .rg8Unorm, .rgba8Unorm,
             .rgba8UnormSrgb, .bgra8Unorm, .bgra8UnormSrgb, .r16Float,
             .rg16Float, .rgba16Float, .r32Float, .rg32Float,
             .rgba32Float, .stencil8:
            return false
        }
    }

    var isStencilFormat: Bool {
        switch self {
        case .stencil8, .depth24UnormStencil8, .depth32FloatStencil8:
            return true
        case .invalid, .r8Unorm, .rg8Unorm, .rgba8Unorm,
             .rgba8UnormSrgb, .bgra8Unorm, .bgra8UnormSrgb, .r16Float,
             .rg16Float, .rgba16Float, .r32Float, .rg32Float,
             .rgba32Float, .depth16Unorm, .depth32Float:
            return false
        }
    }
}

fileprivate extension StorageMode {
    var metalStorageMode: MTLStorageMode {
        switch self {
        case .shared:
            return .shared
        case .managed:
            return .managed
        case .gpuPrivate:
            return .private
        case .memoryless:
            return .memoryless
        }
    }

    var metalResourceOption: MTLResourceOptions {
        switch self {
        case .shared:
            return .storageModeShared
        case .managed:
            return .storageModeManaged
        case .gpuPrivate:
            return .storageModePrivate
        case .memoryless:
            return .storageModeMemoryless
        }
    }

    init(metalStorageMode: MTLStorageMode) {
        switch metalStorageMode {
        case .shared:
            self = .shared
        case .managed:
            self = .managed
        case .private:
            self = .gpuPrivate
        case .memoryless:
            self = .memoryless
        @unknown default:
            self = .gpuPrivate
        }
    }
}

fileprivate extension CpuCacheMode {
    var metalCacheMode: MTLCPUCacheMode {
        switch self {
        case .defaultCache:
            return .defaultCache
        case .writeCombined:
            return .writeCombined
        }
    }

    var metalResourceOption: MTLResourceOptions {
        switch self {
        case .defaultCache:
            return .cpuCacheModeDefaultCache
        case .writeCombined:
            return .cpuCacheModeWriteCombined
        }
    }

    init(metalCacheMode: MTLCPUCacheMode) {
        switch metalCacheMode {
        case .defaultCache:
            self = .defaultCache
        case .writeCombined:
            self = .writeCombined
        @unknown default:
            self = .defaultCache
        }
    }
}

fileprivate extension HazardMode {
    var metalHazardMode: MTLHazardTrackingMode {
        switch self {
        case .defaultMode:
            return .default
        case .untracked:
            return .untracked
        case .tracked:
            return .tracked
        }
    }

    var metalResourceOption: MTLResourceOptions {
        switch self {
        case .defaultMode:
            return .hazardTrackingModeDefault
        case .untracked:
            return .hazardTrackingModeUntracked
        case .tracked:
            return .hazardTrackingModeTracked
        }
    }

    init(metalHazardMode: MTLHazardTrackingMode) {
        switch metalHazardMode {
        case .default:
            self = .defaultMode
        case .untracked:
            self = .untracked
        case .tracked:
            self = .tracked
        @unknown default:
            self = .defaultMode
        }
    }
}

fileprivate extension BufferDescriptor {
    var metalResourceOptions: MTLResourceOptions {
        var options: MTLResourceOptions = []
        options.insert(storageMode.metalResourceOption)
        options.insert(cpuCacheMode.metalResourceOption)
        options.insert(hazardMode.metalResourceOption)
        return options
    }
}

fileprivate extension HeapDescriptor {
    var metalResourceOptions: MTLResourceOptions {
        var options: MTLResourceOptions = []
        options.insert(storageMode.metalResourceOption)
        options.insert(cpuCacheMode.metalResourceOption)
        options.insert(hazardMode.metalResourceOption)
        return options
    }
}

fileprivate extension TextureType {
    var metalTextureType: MTLTextureType {
        switch self {
        case .oneD:
            return .type1D
        case .oneDArray:
            return .type1DArray
        case .twoD:
            return .type2D
        case .twoDArray:
            return .type2DArray
        case .twoDMultisample:
            return .type2DMultisample
        case .twoDMultisampleArray:
            return .type2DMultisampleArray
        case .threeD:
            return .type3D
        case .cube:
            return .typeCube
        case .cubeArray:
            return .typeCubeArray
        }
    }

    var isArray: Bool {
        switch self {
        case .oneDArray, .twoDArray, .twoDMultisampleArray, .cubeArray:
            return true
        case .oneD, .twoD, .twoDMultisample, .threeD, .cube:
            return false
        }
    }

    var isMultisample: Bool {
        switch self {
        case .twoDMultisample, .twoDMultisampleArray:
            return true
        case .oneD, .oneDArray, .twoD, .twoDArray, .threeD, .cube,
             .cubeArray:
            return false
        }
    }
}

fileprivate extension ResourceUsage {
    var metalUsage: MTLResourceUsage {
        switch self {
        case .read:
            return .read
        case .write:
            return .write
        case .readWrite:
            return [.read, .write]
        }
    }
}

fileprivate extension RenderLoadAction {
    var metalLoadAction: MTLLoadAction {
        switch self {
        case .dontCare:
            return .dontCare
        case .load:
            return .load
        case .clear:
            return .clear
        }
    }

    init(metalLoadAction: MTLLoadAction) {
        switch metalLoadAction {
        case .dontCare:
            self = .dontCare
        case .load:
            self = .load
        case .clear:
            self = .clear
        @unknown default:
            self = .dontCare
        }
    }
}

fileprivate extension RenderStoreAction {
    var metalStoreAction: MTLStoreAction {
        switch self {
        case .dontCare:
            return .dontCare
        case .store:
            return .store
        case .multisampleResolve:
            return .multisampleResolve
        }
    }

    init(metalStoreAction: MTLStoreAction) {
        switch metalStoreAction {
        case .dontCare:
            self = .dontCare
        case .store:
            self = .store
        case .multisampleResolve:
            self = .multisampleResolve
        @unknown default:
            self = .dontCare
        }
    }
}

fileprivate extension SamplerFilter {
    var metalFilter: MTLSamplerMinMagFilter {
        switch self {
        case .nearest:
            return .nearest
        case .linear:
            return .linear
        }
    }
}

fileprivate extension SamplerMipFilter {
    var metalFilter: MTLSamplerMipFilter {
        switch self {
        case .notMipmapped:
            return .notMipmapped
        case .nearest:
            return .nearest
        case .linear:
            return .linear
        }
    }
}

fileprivate extension SamplerAddressMode {
    var metalMode: MTLSamplerAddressMode {
        switch self {
        case .clampToEdge:
            return .clampToEdge
        case .mirrorClampToEdge:
            return .mirrorClampToEdge
        case .repeat:
            return .repeat
        case .mirrorRepeat:
            return .mirrorRepeat
        case .clampToZero:
            return .clampToZero
        }
    }
}

fileprivate extension CompareFunction {
    var metalFunction: MTLCompareFunction {
        switch self {
        case .never:
            return .never
        case .less:
            return .less
        case .equal:
            return .equal
        case .lessEqual:
            return .lessEqual
        case .greater:
            return .greater
        case .notEqual:
            return .notEqual
        case .greaterEqual:
            return .greaterEqual
        case .always:
            return .always
        }
    }
}

public struct DeviceInfo {
    public var name: String
    public var registryID: UInt64
    public var type: DeviceType
    public var lowPower: Bool
    public var removable: Bool
    public var recommendedMaxWorkingSetSize: UInt64

    public init(
        name: String,
        registryID: UInt64,
        type: DeviceType,
        lowPower: Bool,
        removable: Bool,
        recommendedMaxWorkingSetSize: UInt64
    ) {
        self.name = name
        self.registryID = registryID
        self.type = type
        self.lowPower = lowPower
        self.removable = removable
        self.recommendedMaxWorkingSetSize = recommendedMaxWorkingSetSize
    }
}

public struct DeviceCapabilities {
    public var macFamily: MetalFamily
    public var appleFamily: MetalFamily
    public var argumentBufferTier: ArgumentBufferTier
    public var unifiedMemory: Bool
    public var indirectCommandBuffers: Bool
    public var meshShaders: Bool
    public var tileShaders: Bool
    public var memorylessAttachments: Bool
    public var rayTracing: Bool
    public var dynamicLibraries: Bool
    public var counterSampling: Bool
    public var maxThreadsPerThreadgroup: UInt32
    public var maxBufferLength: UInt64
    public var maxArgumentBufferSamplerCount: UInt32
    public var maxTextureDimension2D: UInt32
    public var supportedSampleCounts: [UInt32]

    public init(
        macFamily: MetalFamily,
        appleFamily: MetalFamily,
        argumentBufferTier: ArgumentBufferTier,
        unifiedMemory: Bool,
        indirectCommandBuffers: Bool,
        meshShaders: Bool,
        tileShaders: Bool,
        memorylessAttachments: Bool,
        rayTracing: Bool,
        dynamicLibraries: Bool,
        counterSampling: Bool,
        maxThreadsPerThreadgroup: UInt32,
        maxBufferLength: UInt64,
        maxArgumentBufferSamplerCount: UInt32,
        maxTextureDimension2D: UInt32,
        supportedSampleCounts: [UInt32]
    ) {
        self.macFamily = macFamily
        self.appleFamily = appleFamily
        self.argumentBufferTier = argumentBufferTier
        self.unifiedMemory = unifiedMemory
        self.indirectCommandBuffers = indirectCommandBuffers
        self.meshShaders = meshShaders
        self.tileShaders = tileShaders
        self.memorylessAttachments = memorylessAttachments
        self.rayTracing = rayTracing
        self.dynamicLibraries = dynamicLibraries
        self.counterSampling = counterSampling
        self.maxThreadsPerThreadgroup = maxThreadsPerThreadgroup
        self.maxBufferLength = maxBufferLength
        self.maxArgumentBufferSamplerCount = maxArgumentBufferSamplerCount
        self.maxTextureDimension2D = maxTextureDimension2D
        self.supportedSampleCounts = supportedSampleCounts
    }

    public func supports(_ feature: DeviceFeature) -> Bool {
        switch feature {
        case .argumentBuffers:
            return argumentBufferTier != .unsupported
        case .argumentBufferTier2:
            return argumentBufferTier == .tier2
        case .indirectCommandBuffers:
            return indirectCommandBuffers
        case .meshShaders:
            return meshShaders
        case .tileShaders:
            return tileShaders
        case .memorylessAttachments:
            return memorylessAttachments
        case .rayTracing:
            return rayTracing
        case .dynamicLibraries:
            return dynamicLibraries
        case .counterSampling:
            return counterSampling
        }
    }
}

fileprivate func rangeFits(
    length: UInt64,
    offset: UInt64,
    count: UInt64
) -> Bool {
    offset <= length &&
        count <= length - offset &&
        offset <= UInt64(Int.max) &&
        count <= UInt64(Int.max)
}

public final class Buffer {
    fileprivate let native: MTLBuffer
    private let usageStorage: UInt32

    fileprivate init(native: MTLBuffer, usage: UInt32) {
        self.native = native
        self.usageStorage = usage
    }

    public var length: UInt64 {
        UInt64(native.length)
    }

    public var usage: UInt32 {
        usageStorage
    }

    public var storageMode: StorageMode {
        StorageMode(metalStorageMode: native.storageMode)
    }

    public var cpuCacheMode: CpuCacheMode {
        CpuCacheMode(metalCacheMode: native.cpuCacheMode)
    }

    public var hazardMode: HazardMode {
        HazardMode(metalHazardMode: native.hazardTrackingMode)
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isCPUVisible: Bool {
        storageMode == .shared || storageMode == .managed
    }

    public func map() -> UnsafeMutableRawPointer? {
        guard isCPUVisible else {
            return nil
        }
        return native.contents()
    }

    public func unmap() -> Bool {
        isCPUVisible
    }

    public func upload(
        source: UnsafeRawPointer,
        length: UInt64,
        offset: UInt64
    ) -> Bool {
        guard isCPUVisible, rangeFits(
            length: self.length,
            offset: offset,
            count: length
        ) else {
            return false
        }
        native.contents()
            .advanced(by: Int(offset))
            .copyMemory(from: source, byteCount: Int(length))
        if storageMode == .managed {
            native.didModifyRange(
                NSRange(location: Int(offset), length: Int(length))
            )
        }
        return true
    }

    public func read(
        destination: UnsafeMutableRawPointer,
        length: UInt64,
        offset: UInt64
    ) -> Bool {
        guard isCPUVisible, rangeFits(
            length: self.length,
            offset: offset,
            count: length
        ) else {
            return false
        }
        destination.copyMemory(
            from: native.contents().advanced(by: Int(offset)),
            byteCount: Int(length)
        )
        return true
    }

    public func didModifyRange(offset: UInt64, length: UInt64) -> Bool {
        guard storageMode == .managed,
              rangeFits(
                  length: self.length,
                  offset: offset,
                  count: length
              ) else {
            return false
        }
        native.didModifyRange(
            NSRange(location: Int(offset), length: Int(length))
        )
        return true
    }

    public func makeSlice(offset: UInt64, length: UInt64) -> BufferSlice? {
        guard rangeFits(
            length: self.length,
            offset: offset,
            count: length
        ) else {
            return nil
        }
        return BufferSlice(buffer: self, offset: offset, length: length)
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class BufferSlice {
    private let buffer: Buffer
    public let offset: UInt64
    public let length: UInt64

    fileprivate init(buffer: Buffer, offset: UInt64, length: UInt64) {
        self.buffer = buffer
        self.offset = offset
        self.length = length
    }

    public var storageMode: StorageMode {
        buffer.storageMode
    }

    public func map() -> UnsafeMutableRawPointer? {
        buffer.map()?.advanced(by: Int(offset))
    }

    public func upload(
        source: UnsafeRawPointer,
        length: UInt64,
        offset: UInt64
    ) -> Bool {
        guard rangeFits(
            length: self.length,
            offset: offset,
            count: length
        ) else {
            return false
        }
        return buffer.upload(
            source: source,
            length: length,
            offset: self.offset + offset
        )
    }

    public func read(
        destination: UnsafeMutableRawPointer,
        length: UInt64,
        offset: UInt64
    ) -> Bool {
        guard rangeFits(
            length: self.length,
            offset: offset,
            count: length
        ) else {
            return false
        }
        return buffer.read(
            destination: destination,
            length: length,
            offset: self.offset + offset
        )
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        buffer.nativeHandle()
    }
}

public final class DynamicBufferAllocator {
    private let backing: Buffer
    private let alignment: UInt64
    private var cursor: UInt64 = 0

    public init(backing: Buffer, alignment: UInt64) {
        self.backing = backing
        self.alignment = max(1, alignment)
    }

    public var capacity: UInt64 {
        backing.length
    }

    public var used: UInt64 {
        cursor
    }

    public func reset() {
        cursor = 0
    }

    public func allocate(length: UInt64) -> BufferSlice? {
        guard length > 0,
              cursor <= UInt64.max - (alignment - 1) else {
            return nil
        }
        let aligned = ((cursor + alignment - 1) / alignment) * alignment
        guard aligned <= backing.length,
              length <= backing.length - aligned else {
            return nil
        }
        cursor = aligned + length
        return backing.makeSlice(offset: aligned, length: length)
    }
}

public final class Texture {
    fileprivate let native: MTLTexture
    private let usageStorage: UInt32

    fileprivate init(native: MTLTexture, usage: UInt32) {
        self.native = native
        self.usageStorage = usage
    }

    public var textureType: TextureType {
        switch native.textureType {
        case .type1D:
            return .oneD
        case .type1DArray:
            return .oneDArray
        case .type2D:
            return .twoD
        case .type2DArray:
            return .twoDArray
        case .type2DMultisample:
            return .twoDMultisample
        case .type2DMultisampleArray:
            return .twoDMultisampleArray
        case .type3D:
            return .threeD
        case .typeCube:
            return .cube
        case .typeCubeArray:
            return .cubeArray
        @unknown default:
            return .twoD
        }
    }

    public var pixelFormat: PixelFormat {
        PixelFormat(metalFormat: native.pixelFormat)
    }

    public var width: UInt32 {
        UInt32(native.width)
    }

    public var height: UInt32 {
        UInt32(native.height)
    }

    public var depth: UInt32 {
        UInt32(native.depth)
    }

    public var arrayLength: UInt32 {
        UInt32(native.arrayLength)
    }

    public var mipLevelCount: UInt32 {
        UInt32(native.mipmapLevelCount)
    }

    public var sampleCount: UInt32 {
        UInt32(native.sampleCount)
    }

    public var usage: UInt32 {
        usageStorage
    }

    public var storageMode: StorageMode {
        StorageMode(metalStorageMode: native.storageMode)
    }

    public var cpuCacheMode: CpuCacheMode {
        CpuCacheMode(metalCacheMode: native.cpuCacheMode)
    }

    public var hazardMode: HazardMode {
        HazardMode(metalHazardMode: native.hazardTrackingMode)
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func makeView(pixelFormat: PixelFormat) -> TextureView? {
        guard pixelFormat.metalFormat != .invalid,
              (usageStorage & UInt32(
                  TextureUsage.pixelFormatView.rawValue
              )) != 0,
              let view = native.makeTextureView(
                  pixelFormat: pixelFormat.metalFormat
              ) else {
            return nil
        }
        return TextureView(native: view, usage: usageStorage)
    }

    public func replaceBaseLevel2D(
        source: UnsafeRawPointer,
        bytesPerRow: UInt64,
        bytesPerImage: UInt64
    ) -> Bool {
        guard isCPUVisibleTexture,
              native.textureType == .type2D ||
                native.textureType == .type2DArray ||
                native.textureType == .typeCube,
              bytesPerRow > 0,
              bytesPerImage > 0,
              bytesPerRow <= UInt64(Int.max),
              bytesPerImage <= UInt64(Int.max) else {
            return false
        }
        let region = MTLRegionMake2D(0, 0, native.width, native.height)
        native.replace(
            region: region,
            mipmapLevel: 0,
            slice: 0,
            withBytes: source,
            bytesPerRow: Int(bytesPerRow),
            bytesPerImage: Int(bytesPerImage)
        )
        return true
    }

    public func readBaseLevel2D(
        destination: UnsafeMutableRawPointer,
        bytesPerRow: UInt64,
        bytesPerImage: UInt64
    ) -> Bool {
        guard isCPUVisibleTexture,
              native.textureType == .type2D ||
                native.textureType == .type2DArray ||
                native.textureType == .typeCube,
              bytesPerRow > 0,
              bytesPerImage > 0,
              bytesPerRow <= UInt64(Int.max),
              bytesPerImage <= UInt64(Int.max) else {
            return false
        }
        let region = MTLRegionMake2D(0, 0, native.width, native.height)
        native.getBytes(
            destination,
            bytesPerRow: Int(bytesPerRow),
            bytesPerImage: Int(bytesPerImage),
            from: region,
            mipmapLevel: 0,
            slice: 0
        )
        return true
    }

    public var isCPUVisibleTexture: Bool {
        storageMode == .shared || storageMode == .managed
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class TextureView {
    fileprivate let native: MTLTexture
    private let usageStorage: UInt32

    fileprivate init(native: MTLTexture, usage: UInt32) {
        self.native = native
        self.usageStorage = usage
    }

    public var pixelFormat: PixelFormat {
        PixelFormat(metalFormat: native.pixelFormat)
    }

    public var width: UInt32 {
        UInt32(native.width)
    }

    public var height: UInt32 {
        UInt32(native.height)
    }

    public var usage: UInt32 {
        usageStorage
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class Sampler {
    fileprivate let native: MTLSamplerState

    fileprivate init(native: MTLSamplerState) {
        self.native = native
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class RenderTarget {
    public let texture: Texture
    private var resolveTextureStorage: Texture?

    public init(texture: Texture) {
        self.texture = texture
    }

    public var resolveTexture: Texture? {
        resolveTextureStorage
    }

    public func setResolveTexture(_ texture: Texture) -> Bool {
        guard self.texture.sampleCount > 1,
              texture.sampleCount == 1,
              texture.pixelFormat == self.texture.pixelFormat else {
            return false
        }
        resolveTextureStorage = texture
        return true
    }

    public func clearResolveTexture() {
        resolveTextureStorage = nil
    }

    fileprivate var nativeTexture: MTLTexture {
        texture.native
    }

    fileprivate var nativeResolveTexture: MTLTexture? {
        resolveTextureStorage?.native
    }
}

public final class DepthAttachment {
    public let texture: Texture
    public var loadAction: RenderLoadAction
    public var storeAction: RenderStoreAction
    public var clearDepth: Double
    public var clearStencil: UInt32 = 0

    public init(
        texture: Texture,
        loadAction: RenderLoadAction,
        storeAction: RenderStoreAction,
        clearDepth: Double
    ) {
        self.texture = texture
        self.loadAction = loadAction
        self.storeAction = storeAction
        self.clearDepth = clearDepth
    }

    fileprivate var nativeTexture: MTLTexture {
        texture.native
    }
}

public final class Fence {
    fileprivate let native: MTLFence

    fileprivate init(native: MTLFence) {
        self.native = native
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class SharedEvent {
    fileprivate let native: MTLSharedEvent

    fileprivate init(native: MTLSharedEvent) {
        self.native = native
    }

    public var signaledValue: UInt64 {
        get { native.signaledValue }
        set { native.signaledValue = newValue }
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class Heap {
    fileprivate let native: MTLHeap

    fileprivate init(native: MTLHeap) {
        self.native = native
    }

    public var size: UInt64 {
        UInt64(native.size)
    }

    public var usedSize: UInt64 {
        UInt64(native.usedSize)
    }

    public var currentAllocatedSize: UInt64 {
        UInt64(native.currentAllocatedSize)
    }

    public var storageMode: StorageMode {
        StorageMode(metalStorageMode: native.storageMode)
    }

    public var cpuCacheMode: CpuCacheMode {
        CpuCacheMode(metalCacheMode: native.cpuCacheMode)
    }

    public var hazardMode: HazardMode {
        HazardMode(metalHazardMode: native.hazardTrackingMode)
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func maxAvailableSize(alignment: UInt64) -> UInt64 {
        guard alignment > 0, alignment <= UInt64(Int.max) else {
            return 0
        }
        return UInt64(native.maxAvailableSize(alignment: Int(alignment)))
    }

    public func createBuffer(_ descriptor: BufferDescriptor) -> Buffer? {
        guard descriptor.length > 0,
              descriptor.length <= UInt64(Int.max),
              descriptor.storageMode == storageMode,
              descriptor.storageMode != .memoryless else {
            return nil
        }
        guard let buffer = native.makeBuffer(
            length: Int(descriptor.length),
            options: descriptor.metalResourceOptions
        ) else {
            return nil
        }
        if !descriptor.label.isEmpty {
            buffer.label = descriptor.label
        }
        return Buffer(native: buffer, usage: descriptor.usage)
    }

    public func createTexture(_ descriptor: TextureDescriptor) -> Texture? {
        guard descriptor.width > 0,
              descriptor.height > 0,
              descriptor.depth > 0,
              descriptor.mipLevelCount > 0,
              descriptor.sampleCount > 0,
              descriptor.storageMode == storageMode,
              descriptor.pixelFormat != .invalid,
              UInt64(descriptor.width) <= UInt64(Int.max),
              UInt64(descriptor.height) <= UInt64(Int.max),
              UInt64(descriptor.depth) <= UInt64(Int.max),
              UInt64(descriptor.arrayLength) <= UInt64(Int.max),
              UInt64(descriptor.mipLevelCount) <= UInt64(Int.max),
              UInt64(descriptor.sampleCount) <= UInt64(Int.max) else {
            return nil
        }
        let metalDescriptor = MTLTextureDescriptor()
        metalDescriptor.textureType = descriptor.textureType.metalTextureType
        metalDescriptor.pixelFormat = descriptor.pixelFormat.metalFormat
        metalDescriptor.width = Int(descriptor.width)
        metalDescriptor.height = Int(descriptor.height)
        metalDescriptor.depth = Int(descriptor.depth)
        metalDescriptor.arrayLength = max(1, Int(descriptor.arrayLength))
        metalDescriptor.mipmapLevelCount = Int(descriptor.mipLevelCount)
        metalDescriptor.sampleCount = Int(descriptor.sampleCount)
        metalDescriptor.usage = MTLTextureUsage(
            rawValue: UInt(descriptor.usage)
        )
        metalDescriptor.storageMode = descriptor.storageMode.metalStorageMode
        metalDescriptor.cpuCacheMode = descriptor.cpuCacheMode.metalCacheMode
        metalDescriptor.hazardTrackingMode =
            descriptor.hazardMode.metalHazardMode
        guard let texture = native.makeTexture(descriptor: metalDescriptor)
        else {
            return nil
        }
        if !descriptor.label.isEmpty {
            texture.label = descriptor.label
        }
        return Texture(native: texture, usage: descriptor.usage)
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class CommandBuffer {
    private let native: MTLCommandBuffer
    private var activeEncoder: AnyObject?
    private var didCommit = false
    private var completionErrorDescriptionStorage = ""
    private var wrapperErrorDescriptionStorage = ""

    fileprivate init(native: MTLCommandBuffer) {
        self.native = native
        native.addCompletedHandler { [weak self] commandBuffer in
            self?.completionErrorDescriptionStorage =
                commandBuffer.error?.localizedDescription ?? ""
        }
    }

    public var status: CommandBufferStatus {
        switch native.status {
        case .notEnqueued:
            return .notEnqueued
        case .enqueued:
            return .enqueued
        case .committed:
            return .committed
        case .scheduled:
            return .scheduled
        case .completed:
            return .completed
        case .error:
            return .error
        @unknown default:
            return .error
        }
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isCommitted: Bool {
        didCommit
    }

    public var hasActiveEncoder: Bool {
        activeEncoder != nil
    }

    public var errorDescription: String {
        if !completionErrorDescriptionStorage.isEmpty {
            return completionErrorDescriptionStorage
        }
        if !wrapperErrorDescriptionStorage.isEmpty {
            return wrapperErrorDescriptionStorage
        }
        return native.error?.localizedDescription ?? ""
    }

    public func makeRenderEncoder(
        _ descriptor: RenderPassDescriptor
    ) -> RenderEncoder? {
        guard prepareForEncoderCreation() else {
            return nil
        }
        guard descriptor.validate() else {
            wrapperErrorDescriptionStorage = descriptor.validationError
            return nil
        }
        guard let encoder = native.makeRenderCommandEncoder(
            descriptor: descriptor.nativeDescriptor
        ) else {
            wrapperErrorDescriptionStorage =
                "Metal could not create a render command encoder."
            return nil
        }

        let wrapper = RenderEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() }
        )
        activeEncoder = wrapper
        return wrapper
    }

    public func makeComputeEncoder() -> ComputeEncoder? {
        guard prepareForEncoderCreation() else {
            return nil
        }
        guard let encoder = native.makeComputeCommandEncoder() else {
            wrapperErrorDescriptionStorage =
                "Metal could not create a compute command encoder."
            return nil
        }

        let wrapper = ComputeEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() }
        )
        activeEncoder = wrapper
        return wrapper
    }

    public func makeBlitEncoder() -> BlitEncoder? {
        guard prepareForEncoderCreation() else {
            return nil
        }
        guard let encoder = native.makeBlitCommandEncoder() else {
            wrapperErrorDescriptionStorage =
                "Metal could not create a blit command encoder."
            return nil
        }

        let wrapper = BlitEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() }
        )
        activeEncoder = wrapper
        return wrapper
    }

    public func pushDebugGroup(_ name: String) -> Bool {
        guard !didCommit else {
            wrapperErrorDescriptionStorage =
                "Cannot push a debug group after command-buffer commit."
            return false
        }
        native.pushDebugGroup(name)
        return true
    }

    public func popDebugGroup() -> Bool {
        guard !didCommit else {
            wrapperErrorDescriptionStorage =
                "Cannot pop a debug group after command-buffer commit."
            return false
        }
        native.popDebugGroup()
        return true
    }

    public func present(_ drawable: Drawable) -> Bool {
        guard !didCommit, activeEncoder == nil else {
            wrapperErrorDescriptionStorage =
                "The command buffer must be uncommitted and have no active "
                + "encoder before presentation."
            return false
        }
        guard let nativeDrawable = drawable.nativeDrawable else {
            wrapperErrorDescriptionStorage =
                "The drawable is not backed by a presentable CAMetalDrawable."
            return false
        }
        guard !drawable.wasPresented else {
            wrapperErrorDescriptionStorage =
                "The drawable has already been presented."
            return false
        }

        native.present(nativeDrawable)
        drawable.markPresented()
        return true
    }

    public func signal(_ event: SharedEvent, value: UInt64) -> Bool {
        guard !didCommit, activeEncoder == nil else {
            wrapperErrorDescriptionStorage =
                "A shared event must be encoded before commit and outside "
                + "an active encoder."
            return false
        }
        native.encodeSignalEvent(event.native, value: value)
        return true
    }

    public func waitFor(_ event: SharedEvent, value: UInt64) -> Bool {
        guard !didCommit, activeEncoder == nil else {
            wrapperErrorDescriptionStorage =
                "A shared-event wait must be encoded before commit and "
                + "outside an active encoder."
            return false
        }
        native.encodeWaitForEvent(event.native, value: value)
        return true
    }

    public func commit() -> Bool {
        guard !didCommit else {
            wrapperErrorDescriptionStorage =
                "The command buffer has already been committed."
            return false
        }
        guard activeEncoder == nil else {
            wrapperErrorDescriptionStorage =
                "End the active encoder before committing the command buffer."
            return false
        }

        native.commit()
        didCommit = true
        return true
    }

    public func waitUntilScheduled() {
        native.waitUntilScheduled()
    }

    public func waitUntilCompleted() {
        native.waitUntilCompleted()
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }

    private func prepareForEncoderCreation() -> Bool {
        guard !didCommit else {
            wrapperErrorDescriptionStorage =
                "Cannot create an encoder after command-buffer commit."
            return false
        }
        guard activeEncoder == nil else {
            wrapperErrorDescriptionStorage =
                "End the active encoder before creating another encoder."
            return false
        }
        return true
    }

    private func encoderDidEnd() {
        activeEncoder = nil
    }
}

public final class RenderPassDescriptor {
    fileprivate let nativeDescriptor: MTLRenderPassDescriptor
    private var colorTexture: MTLTexture
    private var validationErrorStorage = ""
    private var labelStorage = ""

    fileprivate init(texture: MTLTexture) {
        self.colorTexture = texture
        self.nativeDescriptor = MTLRenderPassDescriptor()
        self.nativeDescriptor.colorAttachments[0].texture = texture
        self.nativeDescriptor.colorAttachments[0].loadAction = .clear
        self.nativeDescriptor.colorAttachments[0].storeAction = .store
    }

    public convenience init(colorTexture: Texture) {
        self.init(texture: colorTexture.native)
    }

    public func setColorAttachment(_ target: RenderTarget) -> Bool {
        guard target.nativeTexture.pixelFormat.isColorFormat,
              (
                  target.nativeResolveTexture == nil ||
                  target.nativeResolveTexture?.pixelFormat ==
                      target.nativeTexture.pixelFormat
              ) else {
            return false
        }
        colorTexture = target.nativeTexture
        nativeDescriptor.colorAttachments[0].texture = target.nativeTexture
        nativeDescriptor.colorAttachments[0].resolveTexture =
            target.nativeResolveTexture
        return true
    }

    public func setDepthAttachment(_ attachment: DepthAttachment) -> Bool {
        guard attachment.nativeTexture.pixelFormat.isDepthFormat,
              attachment.nativeTexture.sampleCount == sampleCount,
              attachment.clearDepth.isFinite,
              attachment.clearDepth >= 0,
              attachment.clearDepth <= 1,
              attachment.storeAction != .multisampleResolve else {
            return false
        }
        let depth = nativeDescriptor.depthAttachment
        depth.texture = attachment.nativeTexture
        depth.loadAction = attachment.loadAction.metalLoadAction
        depth.storeAction = attachment.storeAction.metalStoreAction
        depth.clearDepth = attachment.clearDepth
        return validate()
    }

    public func setStencilAttachment(_ attachment: DepthAttachment) -> Bool {
        guard attachment.nativeTexture.pixelFormat.isStencilFormat,
              attachment.nativeTexture.sampleCount == sampleCount,
              attachment.clearDepth.isFinite,
              attachment.storeAction != .multisampleResolve else {
            return false
        }
        let stencil = nativeDescriptor.stencilAttachment
        stencil.texture = attachment.nativeTexture
        stencil.loadAction = attachment.loadAction.metalLoadAction
        stencil.storeAction = attachment.storeAction.metalStoreAction
        stencil.clearStencil = attachment.clearStencil
        return validate()
    }

    public var hasDepthAttachment: Bool {
        nativeDescriptor.depthAttachment.texture != nil
    }

    public var hasStencilAttachment: Bool {
        nativeDescriptor.stencilAttachment.texture != nil
    }

    public var colorFormat: PixelFormat {
        PixelFormat(metalFormat: colorTexture.pixelFormat)
    }

    public var sampleCount: UInt32 {
        UInt32(colorTexture.sampleCount)
    }

    public var colorLoadAction: RenderLoadAction {
        get {
            RenderLoadAction(
                metalLoadAction:
                    nativeDescriptor.colorAttachments[0].loadAction
            )
        }
        set {
            nativeDescriptor.colorAttachments[0].loadAction =
                newValue.metalLoadAction
        }
    }

    public var colorStoreAction: RenderStoreAction {
        get {
            RenderStoreAction(
                metalStoreAction:
                    nativeDescriptor.colorAttachments[0].storeAction
            )
        }
        set {
            nativeDescriptor.colorAttachments[0].storeAction =
                newValue.metalStoreAction
        }
    }

    public var clearColor: ClearColor {
        get {
            let value = nativeDescriptor.colorAttachments[0].clearColor
            return ClearColor(
                red: value.red,
                green: value.green,
                blue: value.blue,
                alpha: value.alpha
            )
        }
        set {
            nativeDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: newValue.red,
                green: newValue.green,
                blue: newValue.blue,
                alpha: newValue.alpha
            )
        }
    }

    public var label: String {
        get { labelStorage }
        set { labelStorage = newValue }
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func validate() -> Bool {
        validationErrorStorage = ""

        guard nativeDescriptor.colorAttachments[0].texture != nil else {
            validationErrorStorage = "A color attachment texture is required."
            return false
        }
        guard colorFormat.isColorFormat else {
            validationErrorStorage = "The color attachment format is invalid."
            return false
        }

        if colorLoadAction == .clear {
            let clear = clearColor
            let values = [clear.red, clear.green, clear.blue, clear.alpha]
            guard values.allSatisfy({ $0.isFinite }) else {
                validationErrorStorage = "Clear color values must be finite."
                return false
            }
        }

        if colorStoreAction == .multisampleResolve {
            guard sampleCount > 1 else {
                validationErrorStorage =
                    "Multisample resolve requires a multisampled attachment."
                return false
            }
            guard let resolveTexture =
                    nativeDescriptor.colorAttachments[0].resolveTexture,
                  resolveTexture.sampleCount == 1,
                  resolveTexture.pixelFormat == colorTexture.pixelFormat
            else {
                validationErrorStorage =
                    "The resolve texture is incompatible with the color "
                    + "attachment."
                return false
            }
        } else if nativeDescriptor.colorAttachments[0].resolveTexture != nil {
            validationErrorStorage =
                "A resolve texture requires a multisample resolve store action."
            return false
        }

        if let depthTexture = nativeDescriptor.depthAttachment.texture {
            let depthFormat = PixelFormat(metalFormat: depthTexture.pixelFormat)
            guard depthFormat.isDepthFormat,
                  depthTexture.sampleCount == sampleCount,
                  nativeDescriptor.depthAttachment.storeAction !=
                    .multisampleResolve,
                  nativeDescriptor.depthAttachment.clearDepth.isFinite,
                  nativeDescriptor.depthAttachment.clearDepth >= 0,
                  nativeDescriptor.depthAttachment.clearDepth <= 1
            else {
                validationErrorStorage =
                    "Depth attachment format or sample count is invalid."
                return false
            }
        }

        if let stencilTexture = nativeDescriptor.stencilAttachment.texture {
            let stencilFormat = PixelFormat(
                metalFormat: stencilTexture.pixelFormat
            )
            guard stencilFormat.isStencilFormat,
                  stencilTexture.sampleCount == sampleCount,
                  nativeDescriptor.stencilAttachment.storeAction !=
                    .multisampleResolve
            else {
                validationErrorStorage =
                    "Stencil attachment format or sample count is invalid."
                return false
            }
        }

        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(nativeDescriptor).toOpaque()
    }
}

public final class RenderEncoder {
    private let native: MTLRenderCommandEncoder
    private let onEnd: () -> Void
    private var ended = false

    fileprivate init(
        native: MTLRenderCommandEncoder,
        onEnd: @escaping () -> Void
    ) {
        self.native = native
        self.onEnd = onEnd
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isEnded: Bool {
        ended
    }

    public func pushDebugGroup(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.pushDebugGroup(name)
        return true
    }

    public func popDebugGroup() -> Bool {
        guard !ended else {
            return false
        }
        native.popDebugGroup()
        return true
    }

    public func useBuffer(_ buffer: Buffer, usage: ResourceUsage) -> Bool {
        guard !ended else {
            return false
        }
        native.useResource(buffer.native, usage: usage.metalUsage)
        return true
    }

    public func useTexture(_ texture: Texture, usage: ResourceUsage) -> Bool {
        guard !ended else {
            return false
        }
        native.useResource(texture.native, usage: usage.metalUsage)
        return true
    }

    public func updateFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.updateFence(fence.native)
        return true
    }

    public func waitForFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.waitForFence(fence.native)
        return true
    }

    public func endEncoding() -> Bool {
        guard !ended else {
            return false
        }
        native.endEncoding()
        ended = true
        onEnd()
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class ComputeEncoder {
    private let native: MTLComputeCommandEncoder
    private let onEnd: () -> Void
    private var ended = false

    fileprivate init(
        native: MTLComputeCommandEncoder,
        onEnd: @escaping () -> Void
    ) {
        self.native = native
        self.onEnd = onEnd
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isEnded: Bool {
        ended
    }

    public func pushDebugGroup(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.pushDebugGroup(name)
        return true
    }

    public func popDebugGroup() -> Bool {
        guard !ended else {
            return false
        }
        native.popDebugGroup()
        return true
    }

    public func useBuffer(_ buffer: Buffer, usage: ResourceUsage) -> Bool {
        guard !ended else {
            return false
        }
        native.useResource(buffer.native, usage: usage.metalUsage)
        return true
    }

    public func useTexture(_ texture: Texture, usage: ResourceUsage) -> Bool {
        guard !ended else {
            return false
        }
        native.useResource(texture.native, usage: usage.metalUsage)
        return true
    }

    public func updateFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.updateFence(fence.native)
        return true
    }

    public func waitForFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.waitForFence(fence.native)
        return true
    }

    public func endEncoding() -> Bool {
        guard !ended else {
            return false
        }
        native.endEncoding()
        ended = true
        onEnd()
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class BlitEncoder {
    private let native: MTLBlitCommandEncoder
    private let onEnd: () -> Void
    private var ended = false

    fileprivate init(
        native: MTLBlitCommandEncoder,
        onEnd: @escaping () -> Void
    ) {
        self.native = native
        self.onEnd = onEnd
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isEnded: Bool {
        ended
    }

    public func pushDebugGroup(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.pushDebugGroup(name)
        return true
    }

    public func popDebugGroup() -> Bool {
        guard !ended else {
            return false
        }
        native.popDebugGroup()
        return true
    }

    public func updateFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.updateFence(fence.native)
        return true
    }

    public func waitForFence(_ fence: Fence) -> Bool {
        guard !ended else {
            return false
        }
        native.waitForFence(fence.native)
        return true
    }

    public func copyBuffer(
        source: Buffer,
        sourceOffset: UInt64,
        destination: Buffer,
        destinationOffset: UInt64,
        length: UInt64
    ) -> Bool {
        guard !ended,
              rangeFits(
                  length: source.length,
                  offset: sourceOffset,
                  count: length
              ),
              rangeFits(
                  length: destination.length,
                  offset: destinationOffset,
                  count: length
              ) else {
            return false
        }
        native.copy(
            from: source.native,
            sourceOffset: Int(sourceOffset),
            to: destination.native,
            destinationOffset: Int(destinationOffset),
            size: Int(length)
        )
        return true
    }

    public func synchronize(_ buffer: Buffer) -> Bool {
        guard !ended, buffer.storageMode == .managed else {
            return false
        }
        native.synchronize(resource: buffer.native)
        return true
    }

    public func synchronize(_ texture: Texture) -> Bool {
        guard !ended, texture.storageMode == .managed else {
            return false
        }
        native.synchronize(resource: texture.native)
        return true
    }

    public func generateMipmaps(_ texture: Texture) -> Bool {
        guard !ended, texture.mipLevelCount > 1 else {
            return false
        }
        native.generateMipmaps(for: texture.native)
        return true
    }

    public func copyTexture(
        source: Texture,
        destination: Texture
    ) -> Bool {
        guard !ended,
              source.width == destination.width,
              source.height == destination.height,
              source.depth == destination.depth,
              source.arrayLength == destination.arrayLength,
              source.pixelFormat == destination.pixelFormat,
              source.sampleCount == destination.sampleCount,
              source.mipLevelCount > 0,
              destination.mipLevelCount > 0 else {
            return false
        }
        native.copy(
            from: source.native,
            to: destination.native
        )
        return true
    }

    public func endEncoding() -> Bool {
        guard !ended else {
            return false
        }
        native.endEncoding()
        ended = true
        onEnd()
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class CommandQueue {
    private let native: MTLCommandQueue

    fileprivate init(native: MTLCommandQueue) {
        self.native = native
    }

    public func makeCommandBuffer() -> CommandBuffer? {
        guard let commandBuffer = native.makeCommandBuffer() else {
            return nil
        }
        return CommandBuffer(native: commandBuffer)
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class Drawable {
    fileprivate let texture: MTLTexture
    fileprivate let nativeDrawable: MTLDrawable?
    private var presented = false

    fileprivate init(texture: MTLTexture, nativeDrawable: MTLDrawable?) {
        self.texture = texture
        self.nativeDrawable = nativeDrawable
    }

    public var drawableSize: Extent {
        Extent(
            width: UInt32(texture.width),
            height: UInt32(texture.height)
        )
    }

    public var colorFormat: PixelFormat {
        PixelFormat(metalFormat: texture.pixelFormat)
    }

    public var isPresentable: Bool {
        nativeDrawable != nil
    }

    public var wasPresented: Bool {
        presented
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        if let nativeDrawable {
            return Unmanaged.passUnretained(nativeDrawable as AnyObject)
                .toOpaque()
        }
        return Unmanaged.passUnretained(texture as AnyObject).toOpaque()
    }

    fileprivate func markPresented() {
        presented = true
    }
}

public final class Surface {
    private let nativeDevice: MTLDevice
    private let layer: CAMetalLayer?
    private let formatStorage: PixelFormat
    private var offscreenTexture: MTLTexture?
    private var extentStorage: Extent

    fileprivate init(
        device: MTLDevice,
        format: PixelFormat,
        extent: Extent,
        offscreenTexture: MTLTexture?,
        layer: CAMetalLayer?
    ) {
        self.nativeDevice = device
        self.formatStorage = format
        self.extentStorage = extent
        self.offscreenTexture = offscreenTexture
        self.layer = layer
    }

    public static func offscreen(
        device: Device,
        width: UInt32,
        height: UInt32,
        format: PixelFormat
    ) -> Surface? {
        guard width > 0, height > 0, format.isColorFormat else {
            return nil
        }
        guard let texture = makeOffscreenTexture(
            device: device.metalDevice,
            width: width,
            height: height,
            format: format
        ) else {
            return nil
        }
        return Surface(
            device: device.metalDevice,
            format: format,
            extent: Extent(width: width, height: height),
            offscreenTexture: texture,
            layer: nil
        )
    }

    public static func externalTexture(
        nativeTexture: UnsafeMutableRawPointer,
        width: UInt32,
        height: UInt32,
        format: PixelFormat
    ) -> Surface? {
        guard width > 0, height > 0, format.isColorFormat else {
            return nil
        }
        let object = Unmanaged<AnyObject>
            .fromOpaque(nativeTexture)
            .takeUnretainedValue()
        guard let texture = object as? MTLTexture else {
            return nil
        }
        guard texture.width == Int(width), texture.height == Int(height) else {
            return nil
        }
        guard texture.pixelFormat == format.metalFormat else {
            return nil
        }
        return Surface(
            device: texture.device,
            format: format,
            extent: Extent(width: width, height: height),
            offscreenTexture: texture,
            layer: nil
        )
    }

    public static func layerBacked(
        nativeLayer: UnsafeMutableRawPointer
    ) -> Surface? {
        let object = Unmanaged<AnyObject>
            .fromOpaque(nativeLayer)
            .takeUnretainedValue()
        guard let layer = object as? CAMetalLayer else {
            return nil
        }
        guard let device = layer.device ?? MTLCreateSystemDefaultDevice()
        else {
            return nil
        }

        layer.device = device
        let format = PixelFormat(metalFormat: layer.pixelFormat)
        guard format != .invalid else {
            return nil
        }

        let size = Extent(
            width: UInt32(max(0, Int(layer.drawableSize.width))),
            height: UInt32(max(0, Int(layer.drawableSize.height)))
        )
        return Surface(
            device: device,
            format: format,
            extent: size,
            offscreenTexture: nil,
            layer: layer
        )
    }

    public var drawableSize: Extent {
        if let layer {
            return Extent(
                width: UInt32(max(0, Int(layer.drawableSize.width))),
                height: UInt32(max(0, Int(layer.drawableSize.height)))
            )
        }
        return extentStorage
    }

    public var colorFormat: PixelFormat {
        formatStorage
    }

    public var isLayerBacked: Bool {
        layer != nil
    }

    public func resize(width: UInt32, height: UInt32) -> Bool {
        guard width > 0, height > 0 else {
            return false
        }

        if let layer {
            layer.drawableSize = CGSize(
                width: CGFloat(width),
                height: CGFloat(height)
            )
            extentStorage = Extent(width: width, height: height)
            return true
        }

        guard let texture = Self.makeOffscreenTexture(
            device: nativeDevice,
            width: width,
            height: height,
            format: formatStorage
        ) else {
            return false
        }
        offscreenTexture = texture
        extentStorage = Extent(width: width, height: height)
        return true
    }

    public func nextDrawable() -> Drawable? {
        if let layer {
            guard let drawable = layer.nextDrawable() else {
                return nil
            }
            return Drawable(
                texture: drawable.texture,
                nativeDrawable: drawable
            )
        }

        guard let texture = offscreenTexture else {
            return nil
        }
        return Drawable(texture: texture, nativeDrawable: nil)
    }

    public func makeRenderPassDescriptor(
        _ drawable: Drawable
    ) -> RenderPassDescriptor? {
        guard drawable.colorFormat == formatStorage else {
            return nil
        }
        return RenderPassDescriptor(texture: drawable.texture)
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        if let layer {
            return Unmanaged.passUnretained(layer).toOpaque()
        }
        guard let texture = offscreenTexture else {
            preconditionFailure("A non-layer surface must have a texture.")
        }
        return Unmanaged.passUnretained(texture as AnyObject).toOpaque()
    }

    private static func makeOffscreenTexture(
        device: MTLDevice,
        width: UInt32,
        height: UInt32,
        format: PixelFormat
    ) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: format.metalFormat,
            width: Int(width),
            height: Int(height),
            mipmapped: false
        )
        descriptor.usage = [.renderTarget]
        descriptor.storageMode = .gpuPrivate
        return device.makeTexture(descriptor: descriptor)
    }
}

public final class Frame {
    public let commandBuffer: CommandBuffer
    public let drawable: Drawable?
    public let renderPassDescriptor: RenderPassDescriptor?
    public let frameIndex: UInt64
    public let drawableSize: Extent
    private weak var scheduler: FrameScheduler?
    private var ended = false

    fileprivate init(
        scheduler: FrameScheduler,
        commandBuffer: CommandBuffer,
        drawable: Drawable?,
        renderPassDescriptor: RenderPassDescriptor?,
        frameIndex: UInt64,
        drawableSize: Extent
    ) {
        self.scheduler = scheduler
        self.commandBuffer = commandBuffer
        self.drawable = drawable
        self.renderPassDescriptor = renderPassDescriptor
        self.frameIndex = frameIndex
        self.drawableSize = drawableSize
    }

    public var hasDrawable: Bool {
        drawable != nil
    }

    public var isEnded: Bool {
        ended
    }

    fileprivate func belongs(to scheduler: FrameScheduler) -> Bool {
        self.scheduler === scheduler
    }

    fileprivate func markEnded() {
        ended = true
    }
}

public final class FrameScheduler {
    private let queue: CommandQueue
    private var nextFrameIndex: UInt64 = 0

    public init(queue: CommandQueue) {
        self.queue = queue
    }

    public var nextFrame: UInt64 {
        nextFrameIndex
    }

    public func beginFrame(_ surface: Surface) -> Frame? {
        guard let commandBuffer = queue.makeCommandBuffer() else {
            return nil
        }

        let drawable = surface.nextDrawable()
        let renderPassDescriptor = drawable.flatMap {
            surface.makeRenderPassDescriptor($0)
        }
        let frame = Frame(
            scheduler: self,
            commandBuffer: commandBuffer,
            drawable: drawable,
            renderPassDescriptor: renderPassDescriptor,
            frameIndex: nextFrameIndex,
            drawableSize: surface.drawableSize
        )
        nextFrameIndex += 1
        return frame
    }

    public func endFrame(_ frame: Frame, present: Bool) -> Bool {
        guard frame.belongs(to: self), !frame.isEnded else {
            return false
        }
        guard !frame.commandBuffer.isCommitted,
              !frame.commandBuffer.hasActiveEncoder else {
            return false
        }

        if present, let drawable = frame.drawable {
            guard frame.commandBuffer.present(drawable) else {
                return false
            }
        }

        guard frame.commandBuffer.commit() else {
            return false
        }
        frame.markEnded()
        return true
    }
}

public final class Device {
    private let native: MTLDevice

    fileprivate init(native: MTLDevice) {
        self.native = native
    }

    public static func systemDefault() -> Device? {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        return Device(native: device)
    }

    public static func enumerate() -> [DeviceInfo] {
        MTLCopyAllDevices().map(makeDeviceInfo)
    }

    public static func fromRegistryID(_ registryID: UInt64) -> Device? {
        guard let device = MTLCopyAllDevices().first(where: {
            $0.registryID == registryID
        }) else {
            return nil
        }
        return Device(native: device)
    }

    public var info: DeviceInfo {
        Self.makeDeviceInfo(native)
    }

    public var capabilities: DeviceCapabilities {
        Self.makeCapabilities(native)
    }

    fileprivate var metalDevice: MTLDevice {
        native
    }

    public func createBuffer(_ descriptor: BufferDescriptor) -> Buffer? {
        guard descriptor.length > 0,
              descriptor.length <= UInt64(native.maxBufferLength),
              descriptor.length <= UInt64(Int.max),
              descriptor.storageMode != .memoryless else {
            return nil
        }
        guard let buffer = native.makeBuffer(
            length: Int(descriptor.length),
            options: descriptor.metalResourceOptions
        ) else {
            return nil
        }
        if !descriptor.label.isEmpty {
            buffer.label = descriptor.label
        }
        return Buffer(native: buffer, usage: descriptor.usage)
    }

    public func createTexture(_ descriptor: TextureDescriptor) -> Texture? {
        guard descriptor.pixelFormat != .invalid,
              descriptor.width > 0,
              descriptor.height > 0,
              descriptor.depth > 0,
              descriptor.mipLevelCount > 0,
              descriptor.sampleCount > 0,
              UInt64(descriptor.width) <= UInt64(Int.max),
              UInt64(descriptor.height) <= UInt64(Int.max),
              UInt64(descriptor.depth) <= UInt64(Int.max),
              UInt64(descriptor.arrayLength) <= UInt64(Int.max),
              UInt64(descriptor.mipLevelCount) <= UInt64(Int.max),
              UInt64(descriptor.sampleCount) <= UInt64(Int.max) else {
            return nil
        }

        if descriptor.textureType.isArray && descriptor.arrayLength == 0 {
            return nil
        }
        if !descriptor.textureType.isArray && descriptor.arrayLength > 1 {
            return nil
        }
        if descriptor.textureType.isMultisample {
            guard descriptor.sampleCount > 1,
                  descriptor.mipLevelCount == 1,
                  native.supportsTextureSampleCount(
                      Int(descriptor.sampleCount)
                  ) else {
                return nil
            }
        } else if descriptor.sampleCount != 1 {
            return nil
        }
        if descriptor.storageMode == .memoryless {
            guard native.supportsMemorylessRenderTargets,
                  (descriptor.usage & UInt32(
                      TextureUsage.renderTarget.rawValue
                  )) != 0 else {
                return nil
            }
        }

        let metalDescriptor = MTLTextureDescriptor()
        metalDescriptor.textureType = descriptor.textureType.metalTextureType
        metalDescriptor.pixelFormat = descriptor.pixelFormat.metalFormat
        metalDescriptor.width = Int(descriptor.width)
        metalDescriptor.height = Int(descriptor.height)
        metalDescriptor.depth = Int(descriptor.depth)
        metalDescriptor.arrayLength = max(1, Int(descriptor.arrayLength))
        metalDescriptor.mipmapLevelCount = Int(descriptor.mipLevelCount)
        metalDescriptor.sampleCount = Int(descriptor.sampleCount)
        metalDescriptor.usage = MTLTextureUsage(
            rawValue: UInt(descriptor.usage)
        )
        metalDescriptor.storageMode = descriptor.storageMode.metalStorageMode
        metalDescriptor.cpuCacheMode = descriptor.cpuCacheMode.metalCacheMode
        metalDescriptor.hazardTrackingMode =
            descriptor.hazardMode.metalHazardMode

        guard let texture = native.makeTexture(descriptor: metalDescriptor)
        else {
            return nil
        }
        if !descriptor.label.isEmpty {
            texture.label = descriptor.label
        }
        return Texture(native: texture, usage: descriptor.usage)
    }

    public func createSampler(_ descriptor: SamplerDescriptor) -> Sampler? {
        guard descriptor.maxAnisotropy > 0,
              descriptor.lodMinClamp.isFinite,
              descriptor.lodMaxClamp.isFinite,
              descriptor.lodMinClamp <= descriptor.lodMaxClamp else {
            return nil
        }
        let metalDescriptor = MTLSamplerDescriptor()
        metalDescriptor.minFilter = descriptor.minFilter.metalFilter
        metalDescriptor.magFilter = descriptor.magFilter.metalFilter
        metalDescriptor.mipFilter = descriptor.mipFilter.metalFilter
        metalDescriptor.sAddressMode = descriptor.addressModeS.metalMode
        metalDescriptor.tAddressMode = descriptor.addressModeT.metalMode
        metalDescriptor.rAddressMode = descriptor.addressModeR.metalMode
        metalDescriptor.compareFunction =
            descriptor.compareFunction.metalFunction
        metalDescriptor.maxAnisotropy = Int(descriptor.maxAnisotropy)
        metalDescriptor.lodMinClamp = Float(descriptor.lodMinClamp)
        metalDescriptor.lodMaxClamp = Float(descriptor.lodMaxClamp)
        if !descriptor.label.isEmpty {
            metalDescriptor.label = descriptor.label
        }
        guard let sampler = native.makeSamplerState(
            descriptor: metalDescriptor
        ) else {
            return nil
        }
        return Sampler(native: sampler)
    }

    public func createHeap(_ descriptor: HeapDescriptor) -> Heap? {
        guard descriptor.size > 0,
              descriptor.size <= UInt64(Int.max),
              descriptor.storageMode != .memoryless else {
            return nil
        }
        let metalDescriptor = MTLHeapDescriptor()
        metalDescriptor.size = Int(descriptor.size)
        metalDescriptor.storageMode = descriptor.storageMode.metalStorageMode
        metalDescriptor.cpuCacheMode = descriptor.cpuCacheMode.metalCacheMode
        metalDescriptor.hazardTrackingMode =
            descriptor.hazardMode.metalHazardMode
        guard let heap = native.makeHeap(descriptor: metalDescriptor) else {
            return nil
        }
        if !descriptor.label.isEmpty {
            heap.label = descriptor.label
        }
        return Heap(native: heap)
    }

    public func createFence(label: String) -> Fence? {
        guard let fence = native.makeFence() else {
            return nil
        }
        if !label.isEmpty {
            fence.label = label
        }
        return Fence(native: fence)
    }

    public func createSharedEvent(label: String) -> SharedEvent? {
        guard let event = native.makeSharedEvent() else {
            return nil
        }
        if !label.isEmpty {
            event.label = label
        }
        return SharedEvent(native: event)
    }

    public func createDynamicBuffer(
        capacity: UInt64,
        alignment: UInt64,
        label: String
    ) -> DynamicBufferAllocator? {
        let descriptor = BufferDescriptor(
            length: capacity,
            usage: UInt32(
                BufferUsage.uniform.rawValue | BufferUsage.storage.rawValue
            ),
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
        guard let buffer = createBuffer(descriptor) else {
            return nil
        }
        return DynamicBufferAllocator(
            backing: buffer,
            alignment: max(1, alignment)
        )
    }

    public func createCommandQueue(label: String = "") -> CommandQueue? {
        guard let queue = native.makeCommandQueue() else {
            return nil
        }
        if !label.isEmpty {
            queue.label = label
        }
        return CommandQueue(native: queue)
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }

    private static func makeDeviceInfo(_ device: MTLDevice) -> DeviceInfo {
        let type: DeviceType
        if device.hasUnifiedMemory {
            type = .unified
        } else if device.isRemovable {
            type = .external
        } else if device.isLowPower {
            type = .integrated
        } else {
            type = .discrete
        }

        return DeviceInfo(
            name: device.name,
            registryID: device.registryID,
            type: type,
            lowPower: device.isLowPower,
            removable: device.isRemovable,
            recommendedMaxWorkingSetSize: device.recommendedMaxWorkingSetSize
        )
    }

    private static func makeCapabilities(
        _ device: MTLDevice
    ) -> DeviceCapabilities {
        let macFamily: MetalFamily
        if device.supportsFamily(.mac2) {
            macFamily = .mac2
        } else if device.supportsFamily(.mac1) {
            macFamily = .mac1
        } else {
            macFamily = .unknown
        }

        let appleFamily: MetalFamily
        if device.supportsFamily(.apple7) {
            appleFamily = .apple7
        } else if device.supportsFamily(.apple6) {
            appleFamily = .apple6
        } else if device.supportsFamily(.apple5) {
            appleFamily = .apple5
        } else if device.supportsFamily(.apple4) {
            appleFamily = .apple4
        } else if device.supportsFamily(.apple3) {
            appleFamily = .apple3
        } else if device.supportsFamily(.apple2) {
            appleFamily = .apple2
        } else if device.supportsFamily(.apple1) {
            appleFamily = .apple1
        } else {
            appleFamily = .unknown
        }

        let argumentBufferTier: ArgumentBufferTier
        switch device.argumentBuffersSupport {
        case .tier2:
            argumentBufferTier = .tier2
        case .tier1:
            argumentBufferTier = .tier1
        @unknown default:
            argumentBufferTier = .unsupported
        }

        let maxThreads = device.maxThreadsPerThreadgroup
        let maxThreadCount = UInt64(maxThreads.width) *
            UInt64(maxThreads.height) *
            UInt64(maxThreads.depth)

        let sampleCounts = [1, 2, 4, 8, 16].compactMap { count in
            device.supportsTextureSampleCount(count) ? UInt32(count) : nil
        }

        return DeviceCapabilities(
            macFamily: macFamily,
            appleFamily: appleFamily,
            argumentBufferTier: argumentBufferTier,
            unifiedMemory: device.hasUnifiedMemory,
            indirectCommandBuffers: device.supportsIndirectCommandBuffers,
            meshShaders: device.supportsMeshShaders,
            tileShaders: device.supportsTileShaders,
            memorylessAttachments: device.supportsMemorylessRenderTargets,
            rayTracing: device.supportsRaytracing,
            dynamicLibraries: device.supportsDynamicLibraries,
            counterSampling: device.supportsCounterSampling(
                .atStageBoundary),
            maxThreadsPerThreadgroup: UInt32(
                min(maxThreadCount, UInt64(UInt32.max))),
            maxBufferLength: UInt64(device.maxBufferLength),
            maxArgumentBufferSamplerCount: UInt32(
                min(
                    UInt64(device.maxArgumentBufferSamplerCount),
                    UInt64(UInt32.max))),
            maxTextureDimension2D: UInt32(
                min(
                    UInt64(device.maxTextureDimension2D),
                    UInt64(UInt32.max))),
            supportedSampleCounts: sampleCounts
        )
    }
}

