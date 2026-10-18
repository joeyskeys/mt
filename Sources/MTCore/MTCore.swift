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
    case simdGroups
    case simdGroupMatrix
    case fragmentAtomics
}

public enum MetalCapabilityState: Int32 {
    case unknown
    case unavailable
    case unsupported
    case supported
}

public enum MetalCapabilityErrorKind: Int32 {
    case none
    case unavailable
    case unsupported
    case invalid
    case notMeasured
}

public struct MetalCapabilityLimit {
    public var known: Bool
    public var value: UInt64

    public init(known: Bool, value: UInt64) {
        self.known = known
        self.value = value
    }

    public static var unknown: MetalCapabilityLimit {
        MetalCapabilityLimit(known: false, value: 0)
    }

    public static func measured(_ value: UInt64) -> MetalCapabilityLimit {
        MetalCapabilityLimit(known: true, value: value)
    }
}

public struct MetalCapabilityAvailability {
    public var state: MetalCapabilityState
    public var feature: DeviceFeature
    public var operatingSystemMajor: UInt32
    public var operatingSystemMinor: UInt32
    public var macFamily: MetalFamily
    public var appleFamily: MetalFamily
    public var source: String

    public init(
        state: MetalCapabilityState,
        feature: DeviceFeature,
        operatingSystemMajor: UInt32,
        operatingSystemMinor: UInt32,
        macFamily: MetalFamily,
        appleFamily: MetalFamily,
        source: String
    ) {
        self.state = state
        self.feature = feature
        self.operatingSystemMajor = operatingSystemMajor
        self.operatingSystemMinor = operatingSystemMinor
        self.macFamily = macFamily
        self.appleFamily = appleFamily
        self.source = source
    }

    public static var unknown: MetalCapabilityAvailability {
        MetalCapabilityAvailability(
            state: .unknown,
            feature: .argumentBuffers,
            operatingSystemMajor: 0,
            operatingSystemMinor: 0,
            macFamily: .unknown,
            appleFamily: .unknown,
            source: ""
        )
    }

    public var isUsable: Bool {
        state == .supported
    }
}

public struct MetalCapabilityDiagnostic {
    public var kind: MetalCapabilityErrorKind
    public var feature: DeviceFeature
    public var fallbackAvailable: Bool
    public var message: String

    public init(
        kind: MetalCapabilityErrorKind,
        feature: DeviceFeature,
        fallbackAvailable: Bool,
        message: String
    ) {
        self.kind = kind
        self.feature = feature
        self.fallbackAvailable = fallbackAvailable
        self.message = message
    }

    public static var none: MetalCapabilityDiagnostic {
        MetalCapabilityDiagnostic(
            kind: .none,
            feature: .argumentBuffers,
            fallbackAvailable: false,
            message: ""
        )
    }

    public var isError: Bool {
        kind != .none
    }
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

public enum ResourceSyncDirection: Int32 {
    case cpuToGPU
    case gpuToCPU
}

public enum ResourceCompletionState: Int32 {
    case pending
    case scheduled
    case completed
    case failed
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

public enum StencilOperation: Int32 {
    case keep
    case zero
    case replace
    case incrementClamp
    case decrementClamp
    case invert
    case incrementWrap
    case decrementWrap
}

public enum PipelineCacheKind: Int32, Hashable {
    case render
    case compute
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

public enum IndexType: Int32 {
    case uint16
    case uint32
}

public enum AccelerationStructureUsage: Int32 {
    case none = 0
    case refit = 1
    case preferFastBuild = 2
    case extendedLimits = 4
}

public enum AccelerationStructureInstanceDescriptorType: Int32 {
    case standard
    case userID
    case motion
    case indirect
    case indirectMotion
}

public enum AccelerationStructureVertexFormat: Int32 {
    case float2
    case float3
    case float4
}

public enum CounterSamplingPoint: Int32 {
    case atStageBoundary
    case atDrawBoundary
    case atDispatchBoundary
    case atBlitBoundary
    case atTileDispatchBoundary
}

public enum IndirectCommandType: Int32 {
    case draw = 1
    case drawIndexed = 2
    case drawPatches = 4
    case drawIndexedPatches = 8
    case concurrentDispatch = 16
    case concurrentDispatchThreads = 32
}

public enum ShaderFunctionType: Int32 {
    case vertex
    case fragment
    case kernel
    case object
    case mesh
    case tile
    case visible
    case intersection
    case unknown
}

public enum ShaderStage: Int32 {
    case vertex = 1
    case fragment = 2
    case compute = 4
    case object = 8
    case mesh = 16
    case tile = 32
}

public enum BindingKind: Int32 {
    case buffer
    case texture
    case sampler
    case threadgroupMemory
    case argumentBuffer
    case bytes
    case unknown
}

public enum ResourceAccess: Int32 {
    case read
    case write
    case readWrite
    case unknown
}

public enum UpdateFrequency: Int32 {
    case perDraw
    case perMaterial
    case perFrame
    case staticData
}

public enum VertexFormat: Int32 {
    case invalid
    case uchar2
    case uchar4
    case char2
    case char4
    case ushort2
    case ushort4
    case short2
    case short4
    case half2
    case half4
    case float
    case float2
    case float3
    case float4
    case uint
    case uint2
    case uint3
    case uint4
    case int
    case int2
    case int3
    case int4
}

public enum VertexStepFunction: Int32 {
    case constant
    case perVertex
    case perInstance
    case perPatch
    case perPatchControlPoint
}

public enum PrimitiveType: Int32 {
    case point
    case line
    case triangle
}

public enum CullMode: Int32 {
    case none
    case front
    case back
}

public enum Winding: Int32 {
    case clockwise
    case counterClockwise
}

public enum BlendFactor: Int32 {
    case zero
    case one
    case sourceColor
    case oneMinusSourceColor
    case sourceAlpha
    case oneMinusSourceAlpha
    case destinationColor
    case oneMinusDestinationColor
    case destinationAlpha
    case oneMinusDestinationAlpha
    case sourceAlphaSaturated
    case blendColor
    case oneMinusBlendColor
    case blendAlpha
    case oneMinusBlendAlpha
}

public enum BlendOperation: Int32 {
    case add
    case subtract
    case reverseSubtract
    case min
    case max
}

public enum FunctionConstantType: Int32 {
    case bool
    case int32
    case uint32
    case float
    case double
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

public struct Extent3D {
    public var width: UInt32
    public var height: UInt32
    public var depth: UInt32

    public init(width: UInt32, height: UInt32, depth: UInt32) {
        self.width = width
        self.height = height
        self.depth = depth
    }
}

public struct BufferRange {
    public var offset: UInt64
    public var length: UInt64

    public init(offset: UInt64, length: UInt64) {
        self.offset = offset
        self.length = length
    }
}

public struct TextureRegion {
    public var mipLevel: UInt32
    public var slice: UInt32
    public var origin: Extent3D
    public var size: Extent3D

    public init(
        mipLevel: UInt32,
        slice: UInt32,
        origin: Extent3D,
        size: Extent3D
    ) {
        self.mipLevel = mipLevel
        self.slice = slice
        self.origin = origin
        self.size = size
    }
}

public struct TextureTransferDescriptor {
    public var region: TextureRegion
    public var bytesPerRow: UInt64
    public var bytesPerImage: UInt64

    public init(
        region: TextureRegion,
        bytesPerRow: UInt64,
        bytesPerImage: UInt64
    ) {
        self.region = region
        self.bytesPerRow = bytesPerRow
        self.bytesPerImage = bytesPerImage
    }
}

public struct ResourceVersion {
    public var value: UInt64
    public var label: String

    public init(value: UInt64, label: String) {
        self.value = value
        self.label = label
    }
}

public struct MeshDispatchDescriptor {
    public var threadgroups: Extent3D
    public var threadsPerObjectGroup: Extent3D
    public var threadsPerMeshGroup: Extent3D

    public init(
        threadgroups: Extent3D,
        threadsPerObjectGroup: Extent3D,
        threadsPerMeshGroup: Extent3D
    ) {
        self.threadgroups = threadgroups
        self.threadsPerObjectGroup = threadsPerObjectGroup
        self.threadsPerMeshGroup = threadsPerMeshGroup
    }
}

public struct IndirectCommandBufferDescriptor {
    public var commandTypes: UInt32
    public var inheritBuffers: Bool
    public var inheritPipelineState: Bool
    public var maxCommandCount: UInt32
    public var maxVertexBufferBindCount: UInt32
    public var maxFragmentBufferBindCount: UInt32
    public var maxKernelBufferBindCount: UInt32
    public var label: String

    public init(
        commandTypes: UInt32,
        inheritBuffers: Bool,
        inheritPipelineState: Bool,
        maxCommandCount: UInt32,
        maxVertexBufferBindCount: UInt32,
        maxFragmentBufferBindCount: UInt32,
        maxKernelBufferBindCount: UInt32,
        label: String
    ) {
        self.commandTypes = commandTypes
        self.inheritBuffers = inheritBuffers
        self.inheritPipelineState = inheritPipelineState
        self.maxCommandCount = maxCommandCount
        self.maxVertexBufferBindCount = maxVertexBufferBindCount
        self.maxFragmentBufferBindCount = maxFragmentBufferBindCount
        self.maxKernelBufferBindCount = maxKernelBufferBindCount
        self.label = label
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

public struct BindingInfo {
    public var name: String
    public var kind: BindingKind
    public var stages: UInt32
    public var index: UInt32
    public var arrayLength: UInt32
    public var dataSize: UInt32
    public var alignment: UInt32
    public var updateFrequency: UpdateFrequency

    public init(
        name: String,
        kind: BindingKind,
        stages: UInt32,
        index: UInt32,
        arrayLength: UInt32,
        dataSize: UInt32,
        alignment: UInt32,
        updateFrequency: UpdateFrequency
    ) {
        self.name = name
        self.kind = kind
        self.stages = stages
        self.index = index
        self.arrayLength = arrayLength
        self.dataSize = dataSize
        self.alignment = alignment
        self.updateFrequency = updateFrequency
    }
}

public struct PipelineResourceInfo {
    public var name: String
    public var kind: BindingKind
    public var stages: UInt32
    public var index: UInt32
    public var arrayLength: UInt32
    public var dataSize: UInt32
    public var alignment: UInt32
    public var access: ResourceAccess

    public init(
        name: String,
        kind: BindingKind,
        stages: UInt32,
        index: UInt32,
        arrayLength: UInt32,
        dataSize: UInt32,
        alignment: UInt32,
        access: ResourceAccess
    ) {
        self.name = name
        self.kind = kind
        self.stages = stages
        self.index = index
        self.arrayLength = arrayLength
        self.dataSize = dataSize
        self.alignment = alignment
        self.access = access
    }
}

public struct RenderPipelineInfo {
    public var maxThreadsPerThreadgroup: UInt32
    public var imageblockMemoryLength: UInt32
    public var supportsIndirectCommandBuffers: Bool
    public var sampleCount: UInt32
    public var label: String

    public init(
        maxThreadsPerThreadgroup: UInt32,
        imageblockMemoryLength: UInt32,
        supportsIndirectCommandBuffers: Bool,
        sampleCount: UInt32,
        label: String
    ) {
        self.maxThreadsPerThreadgroup = maxThreadsPerThreadgroup
        self.imageblockMemoryLength = imageblockMemoryLength
        self.supportsIndirectCommandBuffers = supportsIndirectCommandBuffers
        self.sampleCount = sampleCount
        self.label = label
    }
}

public struct ColorAttachmentDescriptor {
    public var pixelFormat: PixelFormat
    public var blendingEnabled: Bool
    public var sourceRGBBlendFactor: BlendFactor
    public var destinationRGBBlendFactor: BlendFactor
    public var rgbBlendOperation: BlendOperation
    public var sourceAlphaBlendFactor: BlendFactor
    public var destinationAlphaBlendFactor: BlendFactor
    public var alphaBlendOperation: BlendOperation
    public var writeMask: UInt32

    public init(
        pixelFormat: PixelFormat,
        blendingEnabled: Bool,
        sourceRGBBlendFactor: BlendFactor,
        destinationRGBBlendFactor: BlendFactor,
        rgbBlendOperation: BlendOperation,
        sourceAlphaBlendFactor: BlendFactor,
        destinationAlphaBlendFactor: BlendFactor,
        alphaBlendOperation: BlendOperation,
        writeMask: UInt32
    ) {
        self.pixelFormat = pixelFormat
        self.blendingEnabled = blendingEnabled
        self.sourceRGBBlendFactor = sourceRGBBlendFactor
        self.destinationRGBBlendFactor = destinationRGBBlendFactor
        self.rgbBlendOperation = rgbBlendOperation
        self.sourceAlphaBlendFactor = sourceAlphaBlendFactor
        self.destinationAlphaBlendFactor = destinationAlphaBlendFactor
        self.alphaBlendOperation = alphaBlendOperation
        self.writeMask = writeMask
    }
}

public struct StencilFaceDescriptor {
    public var stencilCompareFunction: CompareFunction
    public var stencilFailureOperation: StencilOperation
    public var depthFailureOperation: StencilOperation
    public var depthStencilPassOperation: StencilOperation
    public var readMask: UInt32
    public var writeMask: UInt32

    public init(
        stencilCompareFunction: CompareFunction,
        stencilFailureOperation: StencilOperation,
        depthFailureOperation: StencilOperation,
        depthStencilPassOperation: StencilOperation,
        readMask: UInt32,
        writeMask: UInt32
    ) {
        self.stencilCompareFunction = stencilCompareFunction
        self.stencilFailureOperation = stencilFailureOperation
        self.depthFailureOperation = depthFailureOperation
        self.depthStencilPassOperation = depthStencilPassOperation
        self.readMask = readMask
        self.writeMask = writeMask
    }

    public static let `default` = StencilFaceDescriptor(
        stencilCompareFunction: .always,
        stencilFailureOperation: .keep,
        depthFailureOperation: .keep,
        depthStencilPassOperation: .keep,
        readMask: UInt32.max,
        writeMask: UInt32.max
    )
}

public struct DepthStencilDescriptor {
    public var depthCompareFunction: CompareFunction
    public var depthWriteEnabled: Bool
    public var frontFaceStencil: StencilFaceDescriptor
    public var backFaceStencil: StencilFaceDescriptor
    public var label: String

    public init(
        depthCompareFunction: CompareFunction,
        depthWriteEnabled: Bool,
        frontFaceStencil: StencilFaceDescriptor,
        backFaceStencil: StencilFaceDescriptor,
        label: String
    ) {
        self.depthCompareFunction = depthCompareFunction
        self.depthWriteEnabled = depthWriteEnabled
        self.frontFaceStencil = frontFaceStencil
        self.backFaceStencil = backFaceStencil
        self.label = label
    }

    public static let `default` = DepthStencilDescriptor(
        depthCompareFunction: .less,
        depthWriteEnabled: true,
        frontFaceStencil: .default,
        backFaceStencil: .default,
        label: ""
    )
}

public struct PipelineCacheKey: Hashable {
    public var deviceRegistryID: UInt64
    public var sdkSignature: String
    public var kind: PipelineCacheKind
    public var shaderSignature: String
    public var layoutSignature: String
    public var descriptorSignature: String

    public init(
        deviceRegistryID: UInt64,
        sdkSignature: String = PipelineCacheKey.currentSDKSignature,
        kind: PipelineCacheKind,
        shaderSignature: String,
        layoutSignature: String,
        descriptorSignature: String
    ) {
        self.deviceRegistryID = deviceRegistryID
        self.sdkSignature = sdkSignature
        self.kind = kind
        self.shaderSignature = shaderSignature
        self.layoutSignature = layoutSignature
        self.descriptorSignature = descriptorSignature
    }

    public var identifier: String {
        [
            String(deviceRegistryID),
            sdkSignature,
            String(kind.rawValue),
            shaderSignature,
            layoutSignature,
            descriptorSignature
        ].joined(separator: "|")
    }

    public static var currentSDKSignature: String {
        "macOS-\(ProcessInfo.processInfo.operatingSystemVersionString)"
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

fileprivate extension StencilOperation {
    var metalOperation: MTLStencilOperation {
        switch self {
        case .keep:
            return .keep
        case .zero:
            return .zero
        case .replace:
            return .replace
        case .incrementClamp:
            return .incrementClamp
        case .decrementClamp:
            return .decrementClamp
        case .invert:
            return .invert
        case .incrementWrap:
            return .incrementWrap
        case .decrementWrap:
            return .decrementWrap
        }
    }
}

fileprivate extension ShaderFunctionType {
    init(metalFunctionType: MTLFunctionType) {
        switch metalFunctionType {
        case .vertex:
            self = .vertex
        case .fragment:
            self = .fragment
        case .kernel:
            self = .kernel
        case .object:
            self = .object
        case .mesh:
            self = .mesh
        case .tile:
            self = .tile
        case .visible:
            self = .visible
        case .intersection:
            self = .intersection
        @unknown default:
            self = .unknown
        }
    }
}

fileprivate extension VertexFormat {
    var metalFormat: MTLVertexFormat {
        switch self {
        case .invalid:
            return .invalid
        case .uchar2:
            return .uchar2
        case .uchar4:
            return .uchar4
        case .char2:
            return .char2
        case .char4:
            return .char4
        case .ushort2:
            return .ushort2
        case .ushort4:
            return .ushort4
        case .short2:
            return .short2
        case .short4:
            return .short4
        case .half2:
            return .half2
        case .half4:
            return .half4
        case .float:
            return .float
        case .float2:
            return .float2
        case .float3:
            return .float3
        case .float4:
            return .float4
        case .uint:
            return .uint
        case .uint2:
            return .uint2
        case .uint3:
            return .uint3
        case .uint4:
            return .uint4
        case .int:
            return .int
        case .int2:
            return .int2
        case .int3:
            return .int3
        case .int4:
            return .int4
        }
    }
}

fileprivate extension VertexStepFunction {
    var metalFunction: MTLVertexStepFunction {
        switch self {
        case .constant:
            return .constant
        case .perVertex:
            return .perVertex
        case .perInstance:
            return .perInstance
        case .perPatch:
            return .perPatch
        case .perPatchControlPoint:
            return .perPatchControlPoint
        }
    }
}

fileprivate extension PrimitiveType {
    var metalPrimitiveType: MTLPrimitiveType {
        switch self {
        case .point:
            return .point
        case .line:
            return .line
        case .triangle:
            return .triangle
        }
    }

    var metalTopology: MTLPrimitiveTopologyClass {
        switch self {
        case .point:
            return .point
        case .line:
            return .line
        case .triangle:
            return .triangle
        }
    }
}

fileprivate extension IndexType {
    var metalIndexType: MTLIndexType {
        switch self {
        case .uint16:
            return .uint16
        case .uint32:
            return .uint32
        }
    }
}

fileprivate extension AccelerationStructureUsage {
    var metalUsage: MTLAccelerationStructureUsage {
        switch self {
        case .none:
            return []
        case .refit:
            return .refit
        case .preferFastBuild:
            return .preferFastBuild
        case .extendedLimits:
            return .extendedLimits
        }
    }
}

fileprivate extension AccelerationStructureInstanceDescriptorType {
    var metalType: MTLAccelerationStructureInstanceDescriptorType {
        MTLAccelerationStructureInstanceDescriptorType(
            rawValue: UInt(rawValue)
        )
    }
}

fileprivate extension AccelerationStructureVertexFormat {
    var metalFormat: MTLAttributeFormat {
        switch self {
        case .float2:
            return .float2
        case .float3:
            return .float3
        case .float4:
            return .float4
        }
    }
}

fileprivate extension CounterSamplingPoint {
    var metalPoint: MTLCounterSamplingPoint {
        switch self {
        case .atStageBoundary:
            return .atStageBoundary
        case .atDrawBoundary:
            return .atDrawBoundary
        case .atDispatchBoundary:
            return .atDispatchBoundary
        case .atBlitBoundary:
            return .atBlitBoundary
        case .atTileDispatchBoundary:
            return .atTileDispatchBoundary
        }
    }
}

fileprivate extension CullMode {
    var metalMode: MTLCullMode {
        switch self {
        case .none:
            return .none
        case .front:
            return .front
        case .back:
            return .back
        }
    }
}

fileprivate extension Winding {
    var metalWinding: MTLWinding {
        switch self {
        case .clockwise:
            return .clockwise
        case .counterClockwise:
            return .counterClockwise
        }
    }
}

fileprivate extension BlendFactor {
    var metalFactor: MTLBlendFactor {
        switch self {
        case .zero:
            return .zero
        case .one:
            return .one
        case .sourceColor:
            return .sourceColor
        case .oneMinusSourceColor:
            return .oneMinusSourceColor
        case .sourceAlpha:
            return .sourceAlpha
        case .oneMinusSourceAlpha:
            return .oneMinusSourceAlpha
        case .destinationColor:
            return .destinationColor
        case .oneMinusDestinationColor:
            return .oneMinusDestinationColor
        case .destinationAlpha:
            return .destinationAlpha
        case .oneMinusDestinationAlpha:
            return .oneMinusDestinationAlpha
        case .sourceAlphaSaturated:
            return .sourceAlphaSaturated
        case .blendColor:
            return .blendColor
        case .oneMinusBlendColor:
            return .oneMinusBlendColor
        case .blendAlpha:
            return .blendAlpha
        case .oneMinusBlendAlpha:
            return .oneMinusBlendAlpha
        }
    }
}

fileprivate extension BlendOperation {
    var metalOperation: MTLBlendOperation {
        switch self {
        case .add:
            return .add
        case .subtract:
            return .subtract
        case .reverseSubtract:
            return .reverseSubtract
        case .min:
            return .min
        case .max:
            return .max
        }
    }
}

fileprivate extension FunctionConstantType {
    var metalDataType: MTLDataType {
        switch self {
        case .bool:
            return .bool
        case .int32:
            return .int
        case .uint32:
            return .uint
        case .float:
            return .float
        case .double:
            return .double
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

public struct MeshShaderCapabilities {
    public var supported: Bool
    public var maxObjectThreadsPerThreadgroup: UInt32
    public var maxMeshThreadsPerThreadgroup: UInt32
    public var maxMeshVertices: UInt32
    public var maxMeshPrimitives: UInt32
    public var payloadBytes: UInt32
    public var availability: MetalCapabilityAvailability
    public var maxObjectThreadsLimit: MetalCapabilityLimit
    public var maxMeshThreadsLimit: MetalCapabilityLimit
    public var maxVerticesLimit: MetalCapabilityLimit
    public var maxPrimitivesLimit: MetalCapabilityLimit
    public var payloadLimit: MetalCapabilityLimit

    public init(
        supported: Bool,
        maxObjectThreadsPerThreadgroup: UInt32,
        maxMeshThreadsPerThreadgroup: UInt32,
        maxMeshVertices: UInt32,
        maxMeshPrimitives: UInt32,
        payloadBytes: UInt32,
        availability: MetalCapabilityAvailability = .unknown,
        maxObjectThreadsLimit: MetalCapabilityLimit = .unknown,
        maxMeshThreadsLimit: MetalCapabilityLimit = .unknown,
        maxVerticesLimit: MetalCapabilityLimit = .unknown,
        maxPrimitivesLimit: MetalCapabilityLimit = .unknown,
        payloadLimit: MetalCapabilityLimit = .unknown
    ) {
        self.supported = supported
        self.maxObjectThreadsPerThreadgroup =
            maxObjectThreadsPerThreadgroup
        self.maxMeshThreadsPerThreadgroup = maxMeshThreadsPerThreadgroup
        self.maxMeshVertices = maxMeshVertices
        self.maxMeshPrimitives = maxMeshPrimitives
        self.payloadBytes = payloadBytes
        self.availability = availability
        self.maxObjectThreadsLimit = maxObjectThreadsLimit
        self.maxMeshThreadsLimit = maxMeshThreadsLimit
        self.maxVerticesLimit = maxVerticesLimit
        self.maxPrimitivesLimit = maxPrimitivesLimit
        self.payloadLimit = payloadLimit
    }
}

public struct ArgumentBufferCapabilities {
    public var supported: Bool
    public var tier: ArgumentBufferTier
    public var maxSamplerCount: UInt32
    public var supportsNestedBuffers: Bool
    public var availability: MetalCapabilityAvailability
    public var maxSamplerCountLimit: MetalCapabilityLimit

    public init(
        supported: Bool,
        tier: ArgumentBufferTier,
        maxSamplerCount: UInt32,
        supportsNestedBuffers: Bool,
        availability: MetalCapabilityAvailability = .unknown,
        maxSamplerCountLimit: MetalCapabilityLimit = .unknown
    ) {
        self.supported = supported
        self.tier = tier
        self.maxSamplerCount = maxSamplerCount
        self.supportsNestedBuffers = supportsNestedBuffers
        self.availability = availability
        self.maxSamplerCountLimit = maxSamplerCountLimit
    }
}

public struct IndirectCommandCapabilities {
    public var supported: Bool
    public var supportsRenderCommands: Bool
    public var supportsComputeCommands: Bool
    public var supportsMeshCommands: Bool
    public var availability: MetalCapabilityAvailability

    public init(
        supported: Bool,
        supportsRenderCommands: Bool,
        supportsComputeCommands: Bool,
        supportsMeshCommands: Bool,
        availability: MetalCapabilityAvailability = .unknown
    ) {
        self.supported = supported
        self.supportsRenderCommands = supportsRenderCommands
        self.supportsComputeCommands = supportsComputeCommands
        self.supportsMeshCommands = supportsMeshCommands
        self.availability = availability
    }
}

public struct TileShaderCapabilities {
    public var supported: Bool
    public var memorylessAttachments: Bool
    public var maxThreadsPerThreadgroup: UInt32
    public var imageblockMemoryLength: UInt32
    public var availability: MetalCapabilityAvailability
    public var maxThreadsLimit: MetalCapabilityLimit
    public var imageblockMemoryLimit: MetalCapabilityLimit

    public init(
        supported: Bool,
        memorylessAttachments: Bool,
        maxThreadsPerThreadgroup: UInt32,
        imageblockMemoryLength: UInt32,
        availability: MetalCapabilityAvailability = .unknown,
        maxThreadsLimit: MetalCapabilityLimit = .unknown,
        imageblockMemoryLimit: MetalCapabilityLimit = .unknown
    ) {
        self.supported = supported
        self.memorylessAttachments = memorylessAttachments
        self.maxThreadsPerThreadgroup = maxThreadsPerThreadgroup
        self.imageblockMemoryLength = imageblockMemoryLength
        self.availability = availability
        self.maxThreadsLimit = maxThreadsLimit
        self.imageblockMemoryLimit = imageblockMemoryLimit
    }
}

public struct RayTracingCapabilities {
    public var supported: Bool
    public var supportsIntersectionFunctions: Bool
    public var supportsMotion: Bool
    public var availability: MetalCapabilityAvailability

    public init(
        supported: Bool,
        supportsIntersectionFunctions: Bool,
        supportsMotion: Bool,
        availability: MetalCapabilityAvailability = .unknown
    ) {
        self.supported = supported
        self.supportsIntersectionFunctions = supportsIntersectionFunctions
        self.supportsMotion = supportsMotion
        self.availability = availability
    }
}

public struct SIMDGroupCapabilities {
    public var supported: Bool
    public var supportsMatrixOperations: Bool
    public var availability: MetalCapabilityAvailability
    public var simdGroupWidthLimit: MetalCapabilityLimit
    public var matrixDimensionLimit: MetalCapabilityLimit

    public init(
        supported: Bool,
        supportsMatrixOperations: Bool,
        availability: MetalCapabilityAvailability,
        simdGroupWidthLimit: MetalCapabilityLimit,
        matrixDimensionLimit: MetalCapabilityLimit
    ) {
        self.supported = supported
        self.supportsMatrixOperations = supportsMatrixOperations
        self.availability = availability
        self.simdGroupWidthLimit = simdGroupWidthLimit
        self.matrixDimensionLimit = matrixDimensionLimit
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
    public var rayTracingMotion: Bool
    public var dynamicLibraries: Bool
    public var counterSampling: Bool
    public var simdGroups: Bool
    public var simdGroupMatrix: Bool
    public var fragmentAtomics: Bool
    public var maxThreadsPerThreadgroup: UInt32
    public var maxBufferLength: UInt64
    public var maxArgumentBufferSamplerCount: UInt32
    public var maxTextureDimension2D: UInt32
    public var maxTextureDimension2DLimit: MetalCapabilityLimit
    public var supportedSampleCounts: [UInt32]
    public var operatingSystemMajor: UInt32
    public var operatingSystemMinor: UInt32
    public var availabilitySource: String

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
        supportedSampleCounts: [UInt32],
        maxTextureDimension2DLimit: MetalCapabilityLimit = .unknown,
        simdGroups: Bool = false,
        simdGroupMatrix: Bool = false,
        fragmentAtomics: Bool = false,
        rayTracingMotion: Bool = false,
        operatingSystemMajor: UInt32 = 0,
        operatingSystemMinor: UInt32 = 0,
        availabilitySource: String = ""
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
        self.rayTracingMotion = rayTracingMotion
        self.dynamicLibraries = dynamicLibraries
        self.counterSampling = counterSampling
        self.simdGroups = simdGroups
        self.simdGroupMatrix = simdGroupMatrix
        self.fragmentAtomics = fragmentAtomics
        self.maxThreadsPerThreadgroup = maxThreadsPerThreadgroup
        self.maxBufferLength = maxBufferLength
        self.maxArgumentBufferSamplerCount = maxArgumentBufferSamplerCount
        self.maxTextureDimension2D = maxTextureDimension2D
        self.maxTextureDimension2DLimit = maxTextureDimension2DLimit
        self.supportedSampleCounts = supportedSampleCounts
        self.operatingSystemMajor = operatingSystemMajor
        self.operatingSystemMinor = operatingSystemMinor
        self.availabilitySource = availabilitySource
    }

    public var meshShaderCapabilities: MeshShaderCapabilities {
        let maxVerticesLimit: MetalCapabilityLimit = .unknown
        let maxPrimitivesLimit: MetalCapabilityLimit = .unknown
        let payloadLimit: MetalCapabilityLimit = .unknown
        return MeshShaderCapabilities(
            supported: meshShaders,
            maxObjectThreadsPerThreadgroup: maxThreadsPerThreadgroup,
            maxMeshThreadsPerThreadgroup: maxThreadsPerThreadgroup,
            maxMeshVertices: UInt32(maxVerticesLimit.value),
            maxMeshPrimitives: UInt32(maxPrimitivesLimit.value),
            payloadBytes: UInt32(payloadLimit.value),
            availability: availability(for: .meshShaders),
            maxObjectThreadsLimit: limit(
                for: .meshShaders,
                value: UInt64(maxThreadsPerThreadgroup)
            ),
            maxMeshThreadsLimit: limit(
                for: .meshShaders,
                value: UInt64(maxThreadsPerThreadgroup)
            ),
            maxVerticesLimit: maxVerticesLimit,
            maxPrimitivesLimit: maxPrimitivesLimit,
            payloadLimit: payloadLimit
        )
    }

    public var argumentBufferCapabilities: ArgumentBufferCapabilities {
        ArgumentBufferCapabilities(
            supported: argumentBufferTier != .unsupported,
            tier: argumentBufferTier,
            maxSamplerCount: maxArgumentBufferSamplerCount,
            supportsNestedBuffers: argumentBufferTier == .tier2,
            availability: availability(for: .argumentBuffers),
            maxSamplerCountLimit: limit(
                for: .argumentBuffers,
                value: UInt64(maxArgumentBufferSamplerCount)
            )
        )
    }

    public var indirectCommandCapabilities: IndirectCommandCapabilities {
        IndirectCommandCapabilities(
            supported: indirectCommandBuffers,
            supportsRenderCommands: indirectCommandBuffers,
            supportsComputeCommands: indirectCommandBuffers,
            supportsMeshCommands: false,
            availability: availability(for: .indirectCommandBuffers)
        )
    }

    public var tileShaderCapabilities: TileShaderCapabilities {
        TileShaderCapabilities(
            supported: tileShaders,
            memorylessAttachments: memorylessAttachments,
            maxThreadsPerThreadgroup: maxThreadsPerThreadgroup,
            imageblockMemoryLength: 0,
            availability: availability(for: .tileShaders),
            maxThreadsLimit: limit(
                for: .tileShaders,
                value: UInt64(maxThreadsPerThreadgroup)
            ),
            imageblockMemoryLimit: .unknown
        )
    }

    public var rayTracingCapabilities: RayTracingCapabilities {
        RayTracingCapabilities(
            supported: rayTracing,
            supportsIntersectionFunctions: rayTracing,
            supportsMotion: rayTracingMotion,
            availability: availability(for: .rayTracing)
        )
    }

    public var simdGroupCapabilities: SIMDGroupCapabilities {
        SIMDGroupCapabilities(
            supported: simdGroups,
            supportsMatrixOperations: simdGroupMatrix,
            availability: availability(for: .simdGroups),
            simdGroupWidthLimit: .unknown,
            matrixDimensionLimit: .unknown
        )
    }

    public func availability(
        for feature: DeviceFeature
    ) -> MetalCapabilityAvailability {
        let supported: Bool
        switch feature {
        case .argumentBuffers:
            supported = argumentBufferTier != .unsupported
        case .argumentBufferTier2:
            supported = argumentBufferTier == .tier2
        case .indirectCommandBuffers:
            supported = indirectCommandBuffers
        case .meshShaders:
            supported = meshShaders
        case .tileShaders:
            supported = tileShaders
        case .memorylessAttachments:
            supported = memorylessAttachments
        case .rayTracing:
            supported = rayTracing
        case .dynamicLibraries:
            supported = dynamicLibraries
        case .counterSampling:
            supported = counterSampling
        case .simdGroups:
            supported = simdGroups
        case .simdGroupMatrix:
            supported = simdGroupMatrix
        case .fragmentAtomics:
            supported = fragmentAtomics
        }

        let state: MetalCapabilityState
        if operatingSystemMajor == 0 {
            state = .unknown
        } else {
            state = supported ? .supported : .unsupported
        }
        return MetalCapabilityAvailability(
            state: state,
            feature: feature,
            operatingSystemMajor: operatingSystemMajor,
            operatingSystemMinor: operatingSystemMinor,
            macFamily: macFamily,
            appleFamily: appleFamily,
            source: availabilitySource
        )
    }

    public func limit(
        for feature: DeviceFeature,
        value: UInt64
    ) -> MetalCapabilityLimit {
        guard availability(for: feature).state == .supported else {
            return .unknown
        }
        return .measured(value)
    }

    public func limit(for feature: DeviceFeature) -> MetalCapabilityLimit {
        switch feature {
        case .argumentBuffers:
            return limit(
                for: feature,
                value: UInt64(maxArgumentBufferSamplerCount)
            )
        case .meshShaders, .tileShaders:
            return limit(
                for: feature,
                value: UInt64(maxThreadsPerThreadgroup)
            )
        case .argumentBufferTier2, .indirectCommandBuffers,
             .memorylessAttachments, .rayTracing, .dynamicLibraries,
             .counterSampling, .simdGroups, .simdGroupMatrix,
             .fragmentAtomics:
            return .unknown
        }
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
        case .simdGroups:
            return simdGroups
        case .simdGroupMatrix:
            return simdGroupMatrix
        case .fragmentAtomics:
            return fragmentAtomics
        }
    }
}

public struct AccelerationStructureSizes {
    public var accelerationStructureSize: UInt64
    public var buildScratchBufferSize: UInt64
    public var refitScratchBufferSize: UInt64

    public init(
        accelerationStructureSize: UInt64,
        buildScratchBufferSize: UInt64,
        refitScratchBufferSize: UInt64
    ) {
        self.accelerationStructureSize = accelerationStructureSize
        self.buildScratchBufferSize = buildScratchBufferSize
        self.refitScratchBufferSize = refitScratchBufferSize
    }
}

public final class TriangleGeometryDescriptor {
    public var vertexBuffer: Buffer?
    public var vertexBufferOffset: UInt64 = 0
    public var vertexStride: UInt64 = 0
    public var vertexFormat: AccelerationStructureVertexFormat = .float3
    public var triangleCount: UInt32 = 0
    public var indexBuffer: Buffer?
    public var indexBufferOffset: UInt64 = 0
    public var indexType: IndexType = .uint32
    public var transformationMatrixBuffer: Buffer?
    public var transformationMatrixBufferOffset: UInt64 = 0
    public var opaque: Bool = false
    public var allowDuplicateIntersectionFunctionInvocation: Bool = false
    public var intersectionFunctionTableOffset: UInt32 = 0
    public var label: String = ""

    private var validationErrorStorage = ""

    public init() {}

    public var validationError: String {
        validationErrorStorage
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard triangleCount > 0, vertexBuffer != nil else {
            validationErrorStorage =
                "Triangle geometry requires a vertex buffer and triangles."
            return false
        }
        let formatSize: UInt64
        switch vertexFormat {
        case .float2:
            formatSize = 8
        case .float3:
            formatSize = 12
        case .float4:
            formatSize = 16
        }
        let stride = vertexStride == 0 ? formatSize : vertexStride
        let vertexCount = UInt64(triangleCount) * 3
        guard stride >= formatSize,
              vertexBufferOffset <= UInt64(Int.max),
              vertexBufferOffset % stride == 0,
              stride <= UInt64(Int.max),
              indexBufferOffset <= UInt64(Int.max),
              transformationMatrixBufferOffset <= UInt64(Int.max),
              transformationMatrixBufferOffset % 4 == 0,
              vertexCount > 0,
              vertexCount - 1 <= (UInt64.max - formatSize) / stride,
              rangeFits(
                  length: vertexBuffer!.length,
                  offset: vertexBufferOffset,
                  count: (vertexCount - 1) * stride + formatSize
              ) else {
            validationErrorStorage =
                "Triangle geometry offsets or stride are invalid."
            return false
        }
        if let indexBuffer {
            let indexStride: UInt64 = indexType == .uint16 ? 2 : 4
            let indexCount = UInt64(triangleCount) * 3
            guard indexBufferOffset % indexStride == 0,
                  indexCount <= UInt64.max / indexStride,
                  rangeFits(
                      length: indexBuffer.length,
                      offset: indexBufferOffset,
                      count: indexCount * indexStride
                  ) else {
                validationErrorStorage =
                    "Triangle geometry indices exceed the index buffer."
                return false
            }
        }
        if let transformationMatrixBuffer {
            guard rangeFits(
                length: transformationMatrixBuffer.length,
                offset: transformationMatrixBufferOffset,
                count: 48
            ) else {
                validationErrorStorage =
                    "The transformation matrix buffer range is invalid."
                return false
            }
        }
        return true
    }

    fileprivate func makeMetalDescriptor()
        -> MTLAccelerationStructureTriangleGeometryDescriptor? {
        guard validate() else {
            return nil
        }
        let descriptor = MTLAccelerationStructureTriangleGeometryDescriptor()
        descriptor.vertexBuffer = vertexBuffer?.native
        descriptor.vertexBufferOffset = Int(vertexBufferOffset)
        descriptor.vertexStride = Int(vertexStride)
        descriptor.vertexFormat = vertexFormat.metalFormat
        descriptor.triangleCount = Int(triangleCount)
        descriptor.indexBuffer = indexBuffer?.native
        descriptor.indexBufferOffset = Int(indexBufferOffset)
        descriptor.indexType = indexType.metalIndexType
        descriptor.transformationMatrixBuffer =
            transformationMatrixBuffer?.native
        descriptor.transformationMatrixBufferOffset =
            Int(transformationMatrixBufferOffset)
        descriptor.opaque = opaque
        descriptor.allowDuplicateIntersectionFunctionInvocation =
            allowDuplicateIntersectionFunctionInvocation
        descriptor.intersectionFunctionTableOffset =
            Int(intersectionFunctionTableOffset)
        descriptor.label = label.isEmpty ? nil : label
        return descriptor
    }
}

public final class MotionTriangleGeometryDescriptor {
    private var vertexBufferStorage: [Buffer] = []
    private var vertexBufferOffsetStorage: [UInt64] = []

    public var vertexStride: UInt64 = 0
    public var vertexFormat: AccelerationStructureVertexFormat = .float3
    public var triangleCount: UInt32 = 0
    public var indexBuffer: Buffer?
    public var indexBufferOffset: UInt64 = 0
    public var indexType: IndexType = .uint32
    public var transformationMatrixBuffer: Buffer?
    public var transformationMatrixBufferOffset: UInt64 = 0
    public var opaque: Bool = false
    public var allowDuplicateIntersectionFunctionInvocation: Bool = false
    public var intersectionFunctionTableOffset: UInt32 = 0
    public var label: String = ""

    private var validationErrorStorage = ""

    public init() {}

    public var keyframeCount: UInt32 {
        UInt32(min(vertexBufferStorage.count, Int(UInt32.max)))
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func addKeyframe(
        buffer: Buffer,
        offset: UInt64
    ) -> Bool {
        guard offset % 4 == 0,
              rangeFits(length: buffer.length, offset: offset, count: 0)
        else {
            validationErrorStorage =
                "Motion keyframe buffer offset is invalid."
            return false
        }
        vertexBufferStorage.append(buffer)
        vertexBufferOffsetStorage.append(offset)
        validationErrorStorage = ""
        return true
    }

    public func clearKeyframes() {
        vertexBufferStorage.removeAll()
        vertexBufferOffsetStorage.removeAll()
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard keyframeCount >= 2,
              keyframeCount <= 4,
              triangleCount > 0,
              vertexBufferStorage.count == vertexBufferOffsetStorage.count
        else {
            validationErrorStorage =
                "Motion triangle geometry requires two to four keyframes "
                + "and a non-zero triangle count."
            return false
        }
        let formatSize: UInt64
        switch vertexFormat {
        case .float2:
            formatSize = 8
        case .float3:
            formatSize = 12
        case .float4:
            formatSize = 16
        }
        let stride = vertexStride == 0 ? formatSize : vertexStride
        let vertexCount = UInt64(triangleCount) * 3
        guard stride >= formatSize,
              stride <= UInt64(Int.max),
              indexBufferOffset <= UInt64(Int.max),
              transformationMatrixOffsetIsValid,
              vertexCount > 0,
              vertexCount - 1 <= (UInt64.max - formatSize) / stride else {
            validationErrorStorage =
                "Motion triangle geometry offsets or stride are invalid."
            return false
        }
        for (buffer, offset) in zip(
            vertexBufferStorage,
            vertexBufferOffsetStorage
        ) {
            guard offset % stride == 0,
                  rangeFits(
                      length: buffer.length,
                      offset: offset,
                      count: (vertexCount - 1) * stride + formatSize
                  ) else {
                validationErrorStorage =
                    "Motion keyframe data exceeds a vertex buffer."
                return false
            }
        }
        if let indexBuffer {
            let indexStride: UInt64 = indexType == .uint16 ? 2 : 4
            let indexCount = UInt64(triangleCount) * 3
            guard indexBufferOffset % indexStride == 0,
                  indexCount <= UInt64.max / indexStride,
                  rangeFits(
                      length: indexBuffer.length,
                      offset: indexBufferOffset,
                      count: indexCount * indexStride
                  ) else {
                validationErrorStorage =
                    "Motion triangle indices exceed the index buffer."
                return false
            }
        }
        if let transformationMatrixBuffer {
            guard rangeFits(
                length: transformationMatrixBuffer.length,
                offset: transformationMatrixBufferOffset,
                count: 48
            ) else {
                validationErrorStorage =
                    "The motion transformation matrix range is invalid."
                return false
            }
        }
        return true
    }

    private var transformationMatrixOffsetIsValid: Bool {
        transformationMatrixBufferOffset <= UInt64(Int.max)
            && transformationMatrixBufferOffset % 4 == 0
    }

    fileprivate func makeMetalDescriptor()
        -> MTLAccelerationStructureMotionTriangleGeometryDescriptor? {
        guard validate() else {
            return nil
        }
        let keyframes = zip(vertexBufferStorage, vertexBufferOffsetStorage)
            .map { buffer, offset in
                let keyframe = MTLMotionKeyframeData()
                keyframe.buffer = buffer.native
                keyframe.offset = Int(offset)
                return keyframe
            }
        let descriptor =
            MTLAccelerationStructureMotionTriangleGeometryDescriptor()
        descriptor.vertexBuffers = keyframes
        descriptor.vertexStride = Int(vertexStride)
        descriptor.vertexFormat = vertexFormat.metalFormat
        descriptor.triangleCount = Int(triangleCount)
        descriptor.indexBuffer = indexBuffer?.native
        descriptor.indexBufferOffset = Int(indexBufferOffset)
        descriptor.indexType = indexType.metalIndexType
        descriptor.transformationMatrixBuffer =
            transformationMatrixBuffer?.native
        descriptor.transformationMatrixBufferOffset =
            Int(transformationMatrixBufferOffset)
        descriptor.opaque = opaque
        descriptor.allowDuplicateIntersectionFunctionInvocation =
            allowDuplicateIntersectionFunctionInvocation
        descriptor.intersectionFunctionTableOffset =
            Int(intersectionFunctionTableOffset)
        descriptor.label = label.isEmpty ? nil : label
        return descriptor
    }

    fileprivate var keyframeResources: [AnyObject] {
        vertexBufferStorage.map { $0 as AnyObject }
            + [indexBuffer, transformationMatrixBuffer].compactMap {
                $0 as AnyObject?
            }
    }
}

public final class BoundingBoxGeometryDescriptor {
    public var boundingBoxBuffer: Buffer?
    public var boundingBoxBufferOffset: UInt64 = 0
    public var boundingBoxStride: UInt64 = 0
    public var boundingBoxCount: UInt32 = 0
    public var opaque: Bool = false
    public var allowDuplicateIntersectionFunctionInvocation: Bool = false
    public var intersectionFunctionTableOffset: UInt32 = 0
    public var label: String = ""

    private var validationErrorStorage = ""

    public init() {}

    public var validationError: String {
        validationErrorStorage
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard boundingBoxCount > 0, let boundingBoxBuffer else {
            validationErrorStorage =
                "Bounding-box geometry requires a buffer and boxes."
            return false
        }
        let minimumStride: UInt64 = 24
        let stride = boundingBoxStride == 0
            ? minimumStride
            : boundingBoxStride
        guard boundingBoxStride == 0 || boundingBoxStride >= minimumStride,
              boundingBoxBufferOffset <= UInt64(Int.max),
              boundingBoxBufferOffset % stride == 0,
              boundingBoxStride <= UInt64(Int.max),
              UInt64(boundingBoxCount) <= UInt64.max / stride,
              (UInt64(boundingBoxCount) - 1) <=
                (UInt64.max - minimumStride) / stride,
              rangeFits(
                  length: boundingBoxBuffer.length,
                  offset: boundingBoxBufferOffset,
                  count: (UInt64(boundingBoxCount) - 1) * stride
                      + minimumStride
              ) else {
            validationErrorStorage =
                "Bounding-box geometry exceeds the bounding-box buffer."
            return false
        }
        return true
    }

    fileprivate func makeMetalDescriptor()
        -> MTLAccelerationStructureBoundingBoxGeometryDescriptor? {
        guard validate() else {
            return nil
        }
        let descriptor =
            MTLAccelerationStructureBoundingBoxGeometryDescriptor()
        descriptor.boundingBoxBuffer = boundingBoxBuffer?.native
        descriptor.boundingBoxBufferOffset = Int(boundingBoxBufferOffset)
        descriptor.boundingBoxStride = Int(boundingBoxStride)
        descriptor.boundingBoxCount = Int(boundingBoxCount)
        descriptor.opaque = opaque
        descriptor.allowDuplicateIntersectionFunctionInvocation =
            allowDuplicateIntersectionFunctionInvocation
        descriptor.intersectionFunctionTableOffset =
            Int(intersectionFunctionTableOffset)
        descriptor.label = label.isEmpty ? nil : label
        return descriptor
    }
}

public final class PrimitiveAccelerationStructureDescriptor {
    private var triangleGeometryStorage: [TriangleGeometryDescriptor] = []
    private var motionTriangleGeometryStorage:
        [MotionTriangleGeometryDescriptor] = []
    private var boundingBoxGeometryStorage: [BoundingBoxGeometryDescriptor] =
        []
    private var validationErrorStorage = ""

    public var usage: UInt32 = 0
    public var label: String = ""

    public init() {}

    public var triangleGeometryCount: UInt32 {
        UInt32(min(triangleGeometryStorage.count, Int(UInt32.max)))
    }

    public var boundingBoxGeometryCount: UInt32 {
        UInt32(min(boundingBoxGeometryStorage.count, Int(UInt32.max)))
    }

    public var motionTriangleGeometryCount: UInt32 {
        UInt32(min(motionTriangleGeometryStorage.count, Int(UInt32.max)))
    }

    public var geometryCount: UInt32 {
        triangleGeometryCount
            + motionTriangleGeometryCount
            + boundingBoxGeometryCount
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func addTriangleGeometry(
        _ descriptor: TriangleGeometryDescriptor
    ) -> Bool {
        guard descriptor.validate() else {
            validationErrorStorage = descriptor.validationError
            return false
        }
        triangleGeometryStorage.append(descriptor)
        validationErrorStorage = ""
        return true
    }

    public func addBoundingBoxGeometry(
        _ descriptor: BoundingBoxGeometryDescriptor
    ) -> Bool {
        guard descriptor.validate() else {
            validationErrorStorage = descriptor.validationError
            return false
        }
        boundingBoxGeometryStorage.append(descriptor)
        validationErrorStorage = ""
        return true
    }

    public func addMotionTriangleGeometry(
        _ descriptor: MotionTriangleGeometryDescriptor
    ) -> Bool {
        guard descriptor.validate() else {
            validationErrorStorage = descriptor.validationError
            return false
        }
        motionTriangleGeometryStorage.append(descriptor)
        validationErrorStorage = ""
        return true
    }

    public func clearGeometry() {
        triangleGeometryStorage.removeAll()
        motionTriangleGeometryStorage.removeAll()
        boundingBoxGeometryStorage.removeAll()
        validationErrorStorage = ""
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard geometryCount > 0 else {
            validationErrorStorage =
                "A primitive acceleration structure needs geometry."
            return false
        }
        if !motionTriangleGeometryStorage.isEmpty {
            guard triangleGeometryStorage.isEmpty,
                  boundingBoxGeometryStorage.isEmpty else {
                validationErrorStorage =
                    "Motion acceleration structures cannot mix motion and "
                    + "non-motion geometry."
                return false
            }
            let keyframeCounts = Set(
                motionTriangleGeometryStorage.map(\.keyframeCount)
            )
            guard keyframeCounts.count == 1 else {
                validationErrorStorage =
                    "All motion geometry must use the same keyframe count."
                return false
            }
        }
        for descriptor in triangleGeometryStorage
            where !descriptor.validate()
        {
            validationErrorStorage = descriptor.validationError
            return false
        }
        for descriptor in motionTriangleGeometryStorage
            where !descriptor.validate()
        {
            validationErrorStorage = descriptor.validationError
            return false
        }
        for descriptor in boundingBoxGeometryStorage
            where !descriptor.validate()
        {
            validationErrorStorage = descriptor.validationError
            return false
        }
        return true
    }

    fileprivate func makeMetalDescriptor()
        -> MTLPrimitiveAccelerationStructureDescriptor? {
        guard validate() else {
            return nil
        }
        let descriptor = MTLPrimitiveAccelerationStructureDescriptor()
        let triangleDescriptors = triangleGeometryStorage.compactMap {
            $0.makeMetalDescriptor()
        }
        let motionTriangleDescriptors = motionTriangleGeometryStorage.compactMap {
            $0.makeMetalDescriptor()
        }
        let boundingBoxDescriptors = boundingBoxGeometryStorage.compactMap {
            $0.makeMetalDescriptor()
        }
        guard triangleDescriptors.count == triangleGeometryStorage.count,
              motionTriangleDescriptors.count
                == motionTriangleGeometryStorage.count,
              boundingBoxDescriptors.count == boundingBoxGeometryStorage.count
        else {
            return nil
        }
        descriptor.geometryDescriptors =
            triangleDescriptors
                + motionTriangleDescriptors
                + boundingBoxDescriptors
        if let keyframeCount = motionTriangleGeometryStorage.first?
            .keyframeCount {
            descriptor.motionKeyframeCount = Int(keyframeCount)
        }
        descriptor.usage = MTLAccelerationStructureUsage(
            rawValue: UInt(usage)
        )
        return descriptor
    }

    fileprivate var referencedResources: [AnyObject] {
        triangleGeometryStorage.flatMap { descriptor in
            [descriptor.vertexBuffer, descriptor.indexBuffer,
             descriptor.transformationMatrixBuffer].compactMap {
                $0 as AnyObject?
             }
        } + motionTriangleGeometryStorage.flatMap { descriptor in
            descriptor.keyframeResources
        } + boundingBoxGeometryStorage.flatMap { descriptor in
            [descriptor.boundingBoxBuffer].compactMap { $0 as AnyObject? }
        }
    }
}

public final class InstanceAccelerationStructureDescriptor {
    private var accelerationStructureStorage: [AccelerationStructure] = []
    private var validationErrorStorage = ""

    public var instanceCount: UInt32 = 0
    public var instanceDescriptorBuffer: Buffer?
    public var instanceDescriptorBufferOffset: UInt64 = 0
    public var instanceDescriptorStride: UInt64 = 0
    public var instanceDescriptorType:
        AccelerationStructureInstanceDescriptorType = .standard
    public var motionTransformBuffer: Buffer?
    public var motionTransformBufferOffset: UInt64 = 0
    public var motionTransformCount: UInt32 = 0
    public var label: String = ""

    public init() {}

    public var accelerationStructureCount: UInt32 {
        UInt32(min(accelerationStructureStorage.count, Int(UInt32.max)))
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func addAccelerationStructure(
        _ accelerationStructure: AccelerationStructure
    ) -> Bool {
        accelerationStructureStorage.append(accelerationStructure)
        return true
    }

    public func clearAccelerationStructures() {
        accelerationStructureStorage.removeAll()
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard instanceCount > 0,
              let instanceDescriptorBuffer,
              accelerationStructureCount > 0 else {
            validationErrorStorage =
                "An instance acceleration structure requires instances, "
                + "a descriptor buffer, and bottom-level structures."
            return false
        }
        guard instanceDescriptorType != .indirect,
              instanceDescriptorType != .indirectMotion else {
            validationErrorStorage =
                "Indirect instance descriptors require a dedicated indirect "
                + "acceleration-structure descriptor."
            return false
        }
        if instanceDescriptorType == .motion {
            guard let motionTransformBuffer,
                  motionTransformCount > 0,
                  motionTransformBufferOffset % 64 == 0,
                  rangeFits(
                      length: motionTransformBuffer.length,
                      offset: motionTransformBufferOffset,
                      count: UInt64(motionTransformCount) * 48
                  ) else {
                validationErrorStorage =
                    "Motion instances require a valid transform buffer."
                return false
            }
        }
        let minimumStride: UInt64
        switch instanceDescriptorType {
        case .standard, .userID, .motion:
            minimumStride = 64
        case .indirect, .indirectMotion:
            minimumStride = 0
        }
        let stride = instanceDescriptorStride == 0
            ? minimumStride
            : instanceDescriptorStride
        guard stride >= minimumStride,
              stride % 4 == 0,
              instanceDescriptorBufferOffset % 64 == 0,
              instanceDescriptorBufferOffset <= UInt64(Int.max),
              motionTransformBufferOffset <= UInt64(Int.max),
              stride <= UInt64(Int.max),
              UInt64(instanceCount) <= UInt64.max / stride,
              rangeFits(
                  length: instanceDescriptorBuffer.length,
                  offset: instanceDescriptorBufferOffset,
                  count: UInt64(instanceCount) * stride
              ) else {
            validationErrorStorage =
                "The instance descriptor buffer range or stride is invalid."
            return false
        }
        return true
    }

    fileprivate func makeMetalDescriptor()
        -> MTLInstanceAccelerationStructureDescriptor? {
        guard validate() else {
            return nil
        }
        let descriptor = MTLInstanceAccelerationStructureDescriptor()
        descriptor.instanceCount = Int(instanceCount)
        descriptor.instanceDescriptorBuffer = self.instanceDescriptorBuffer?.native
        descriptor.instanceDescriptorBufferOffset =
            Int(instanceDescriptorBufferOffset)
        descriptor.instanceDescriptorStride = Int(instanceDescriptorStride)
        descriptor.instanceDescriptorType = instanceDescriptorType.metalType
        descriptor.motionTransformBuffer = motionTransformBuffer?.native
        descriptor.motionTransformBufferOffset = Int(
            motionTransformBufferOffset
        )
        descriptor.motionTransformCount = Int(motionTransformCount)
        descriptor.instancedAccelerationStructures =
            accelerationStructureStorage.map(\.native)
        return descriptor
    }

    fileprivate var referencedResources: [AnyObject] {
        accelerationStructureStorage.map { $0 as AnyObject }
            + [
                instanceDescriptorBuffer,
                motionTransformBuffer
            ].compactMap { $0 as AnyObject? }
    }
}

public final class AccelerationStructure {
    fileprivate let native: MTLAccelerationStructure
    public let sizes: AccelerationStructureSizes
    private var labelStorage = ""

    fileprivate init(
        native: MTLAccelerationStructure,
        sizes: AccelerationStructureSizes,
        label: String
    ) {
        self.native = native
        self.sizes = sizes
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var size: UInt64 {
        sizes.accelerationStructureSize
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public struct CounterDescription {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

public struct CounterSetDescription {
    public var name: String
    public var counters: [CounterDescription]

    public init(name: String, counters: [CounterDescription]) {
        self.name = name
        self.counters = counters
    }
}

public struct CounterSampleResolution {
    public var rangeStart: UInt32
    public var sampleCount: UInt32
    public var data: [UInt8]

    public init(
        rangeStart: UInt32,
        sampleCount: UInt32,
        data: [UInt8]
    ) {
        self.rangeStart = rangeStart
        self.sampleCount = sampleCount
        self.data = data
    }
}

public final class CounterSampleBuffer {
    fileprivate let native: MTLCounterSampleBuffer
    public let sampleCount: UInt32
    public let storageMode: StorageMode
    public let counterSetName: String
    private var labelStorage = ""
    private var errorDescriptionStorage = ""

    fileprivate init(
        native: MTLCounterSampleBuffer,
        sampleCount: UInt32,
        storageMode: StorageMode,
        counterSetName: String,
        label: String
    ) {
        self.native = native
        self.sampleCount = sampleCount
        self.storageMode = storageMode
        self.counterSetName = counterSetName
        self.labelStorage = label
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
        }
    }

    public var isCPUReadable: Bool {
        storageMode == .shared
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func resolve(
        rangeStart: UInt32,
        sampleCount: UInt32
    ) -> CounterSampleResolution? {
        guard isCPUReadable,
              sampleCount > 0,
              rangeStart <= self.sampleCount,
              sampleCount <= self.sampleCount - rangeStart,
              UInt64(rangeStart) <= UInt64(Int.max),
              UInt64(sampleCount) <= UInt64(Int.max) else {
            errorDescriptionStorage =
                "Counter resolution requires a valid shared-storage range."
            return nil
        }
        do {
            guard let data = try native.resolveCounterRange(
                Int(rangeStart)..<Int(rangeStart + sampleCount)
            ) else {
                errorDescriptionStorage =
                    "Metal returned no data for the counter range."
                return nil
            }
            errorDescriptionStorage = ""
            return CounterSampleResolution(
                rangeStart: rangeStart,
                sampleCount: sampleCount,
                data: Array(data)
            )
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
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

fileprivate func textureMipExtent(
    _ texture: MTLTexture,
    mipLevel: UInt32
) -> Extent3D? {
    guard mipLevel < UInt32(texture.mipmapLevelCount) else {
        return nil
    }
    let shift = Int(mipLevel)
    guard shift < 32 else {
        return nil
    }
    return Extent3D(
        width: max(1, UInt32(texture.width) >> shift),
        height: max(1, UInt32(texture.height) >> shift),
        depth: max(1, UInt32(texture.depth) >> shift)
    )
}

fileprivate func textureSliceCount(_ texture: MTLTexture) -> UInt32 {
    switch texture.textureType {
    case .typeCube:
        return 6
    case .typeCubeArray:
        return max(1, UInt32(texture.arrayLength)) * 6
    default:
        return max(1, UInt32(texture.arrayLength))
    }
}

fileprivate func textureRegionFits(
    _ texture: MTLTexture,
    region: TextureRegion
) -> Bool {
    guard texture.sampleCount == 1,
          region.origin.width <= UInt32(Int.max),
          region.origin.height <= UInt32(Int.max),
          region.origin.depth <= UInt32(Int.max),
          region.size.width > 0,
          region.size.height > 0,
          region.size.depth > 0,
          let extent = textureMipExtent(texture, mipLevel: region.mipLevel)
    else {
        return false
    }

    let isThreeDimensional = texture.textureType == .type3D
    if isThreeDimensional {
        guard region.slice == 0 else {
            return false
        }
    } else if texture.textureType == .type1D {
        guard region.slice == 0,
              region.origin.height == 0,
              region.origin.depth == 0,
              region.size.height == 1,
              region.size.depth == 1 else {
            return false
        }
    } else {
        guard region.slice < textureSliceCount(texture),
              region.size.depth == 1 else {
            return false
        }
    }

    return region.origin.width <= extent.width &&
        region.origin.height <= extent.height &&
        region.origin.depth <= extent.depth &&
        region.size.width <= extent.width - region.origin.width &&
        region.size.height <= extent.height - region.origin.height &&
        region.size.depth <= extent.depth - region.origin.depth
}

fileprivate func metalRegion(_ region: TextureRegion) -> MTLRegion? {
    guard let origin = metalSize(region.origin),
          let size = metalSize(region.size) else {
        return nil
    }
    return MTLRegionMake3D(
        origin.width,
        origin.height,
        origin.depth,
        size.width,
        size.height,
        size.depth
    )
}

fileprivate func bytesPerPixel(_ format: MTLPixelFormat) -> UInt64? {
    switch format {
    case .r8Unorm:
        return 1
    case .rg8Unorm:
        return 2
    case .rgba8Unorm, .rgba8Unorm_sRGB,
         .bgra8Unorm, .bgra8Unorm_sRGB:
        return 4
    case .r16Float:
        return 2
    case .rg16Float:
        return 4
    case .rgba16Float:
        return 8
    case .r32Float:
        return 4
    case .rg32Float:
        return 8
    case .rgba32Float:
        return 16
    case .depth16Unorm:
        return 2
    case .depth32Float:
        return 4
    case .stencil8:
        return 1
    case .depth24Unorm_stencil8:
        return 4
    case .depth32Float_stencil8:
        return 8
    default:
        return nil
    }
}

fileprivate func textureTransferFits(
    _ texture: MTLTexture,
    descriptor: TextureTransferDescriptor
) -> Bool {
    guard textureRegionFits(texture, region: descriptor.region),
          descriptor.bytesPerRow > 0,
          descriptor.bytesPerImage > 0,
          descriptor.bytesPerRow <= UInt64(Int.max),
          descriptor.bytesPerImage <= UInt64(Int.max),
          let bytesPerTexel = bytesPerPixel(texture.pixelFormat),
          descriptor.region.size.width <= UInt32.max / UInt32(bytesPerTexel)
    else {
        return false
    }

    let minimumRowBytes =
        UInt64(descriptor.region.size.width) * bytesPerTexel
    guard descriptor.bytesPerRow >= minimumRowBytes,
          descriptor.region.size.height <= UInt32.max
    else {
        return false
    }

    let minimumImageBytes =
        descriptor.bytesPerRow * UInt64(descriptor.region.size.height)
    guard descriptor.bytesPerImage >= minimumImageBytes else {
        return false
    }

    let imageCount =
        texture.textureType == .type3D
            ? UInt64(descriptor.region.size.depth)
            : 1
    guard imageCount > 0,
          imageCount <= UInt64.max / descriptor.bytesPerImage else {
        return false
    }
    return descriptor.bytesPerImage * imageCount <= UInt64(Int.max)
}

fileprivate func textureTransferByteCount(
    _ texture: MTLTexture,
    descriptor: TextureTransferDescriptor
) -> UInt64? {
    guard textureTransferFits(texture, descriptor: descriptor),
          let bytesPerTexel = bytesPerPixel(texture.pixelFormat) else {
        return nil
    }
    let rowBytes =
        UInt64(descriptor.region.size.width) * bytesPerTexel
    let rowCount = UInt64(descriptor.region.size.height)
    let imageCount =
        texture.textureType == .type3D
            ? UInt64(descriptor.region.size.depth)
            : 1
    guard rowCount > 0, imageCount > 0,
          imageCount - 1 <= UInt64.max / descriptor.bytesPerImage,
          rowCount - 1 <= UInt64.max / descriptor.bytesPerRow else {
        return nil
    }
    let lastImageOffset =
        (imageCount - 1) * descriptor.bytesPerImage
    let lastRowOffset =
        (rowCount - 1) * descriptor.bytesPerRow
    guard lastImageOffset <= UInt64.max - lastRowOffset else {
        return nil
    }
    let lastOffset = lastImageOffset + lastRowOffset
    guard lastOffset <= UInt64.max - rowBytes else {
        return nil
    }
    return lastOffset + rowBytes
}

fileprivate func metalSize(_ extent: Extent3D) -> MTLSize? {
    guard extent.width > 0,
          extent.height > 0,
          extent.depth > 0,
          UInt64(extent.width) <= UInt64(Int.max),
          UInt64(extent.height) <= UInt64(Int.max),
          UInt64(extent.depth) <= UInt64(Int.max) else {
        return nil
    }
    return MTLSize(
        width: Int(extent.width),
        height: Int(extent.height),
        depth: Int(extent.depth)
    )
}

fileprivate func boundedUInt32(_ value: Int) -> UInt32 {
    UInt32(min(max(value, 0), Int(UInt32.max)))
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

    public var isShared: Bool {
        storageMode == .shared
    }

    public var isManaged: Bool {
        storageMode == .managed
    }

    public var isPrivate: Bool {
        storageMode == .gpuPrivate
    }

    public func validateRange(_ range: BufferRange) -> Bool {
        rangeFits(
            length: self.length,
            offset: range.offset,
            count: range.length
        )
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

    public func uploadRange(
        source: UnsafeRawPointer,
        range: BufferRange
    ) -> Bool {
        upload(
            source: source,
            length: range.length,
            offset: range.offset
        )
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

    public func readRange(
        destination: UnsafeMutableRawPointer,
        range: BufferRange
    ) -> Bool {
        read(
            destination: destination,
            length: range.length,
            offset: range.offset
        )
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

    public func synchronizeForCPUToGPU(
        range: BufferRange
    ) -> Bool {
        didModifyRange(offset: range.offset, length: range.length)
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
    private var inFlightTokens: [CompletionToken] = []

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

    public var inFlightCount: UInt32 {
        UInt32(min(inFlightTokens.count, Int(UInt32.max)))
    }

    public var availableCapacity: UInt64 {
        backing.length >= cursor ? backing.length - cursor : 0
    }

    public func reset() {
        _ = reclaimCompleted()
        guard inFlightTokens.isEmpty else {
            return
        }
        cursor = 0
    }

    public func resetIfIdle() -> Bool {
        _ = reclaimCompleted()
        guard inFlightTokens.isEmpty else {
            return false
        }
        cursor = 0
        return true
    }

    public func markInFlight(_ token: CompletionToken) -> Bool {
        _ = reclaimCompleted()
        guard !token.isComplete else {
            return false
        }
        inFlightTokens.append(token)
        return true
    }

    public func seal(for commandBuffer: CommandBuffer) -> Bool {
        markInFlight(commandBuffer.makeCompletionToken())
    }

    @discardableResult
    public func reclaimCompleted() -> UInt32 {
        let originalCount = inFlightTokens.count
        inFlightTokens.removeAll { $0.isComplete }
        return UInt32(
            min(originalCount - inFlightTokens.count, Int(UInt32.max))
        )
    }

    public func allocate(length: UInt64) -> BufferSlice? {
        _ = reclaimCompleted()
        guard inFlightTokens.isEmpty else {
            return nil
        }
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

    public func uploadRegion(
        source: UnsafeRawPointer,
        transfer: TextureTransferDescriptor
    ) -> Bool {
        guard isCPUVisibleTexture,
              textureTransferFits(native, descriptor: transfer),
              let region = metalRegion(transfer.region) else {
            return false
        }

        if native.textureType == .type1D {
            native.replace(
                region: MTLRegionMake1D(
                    Int(transfer.region.origin.width),
                    Int(transfer.region.size.width)
                ),
                mipmapLevel: Int(transfer.region.mipLevel),
                withBytes: source,
                bytesPerRow: Int(transfer.bytesPerRow)
            )
        } else {
            native.replace(
                region: region,
                mipmapLevel: Int(transfer.region.mipLevel),
                slice: Int(transfer.region.slice),
                withBytes: source,
                bytesPerRow: Int(transfer.bytesPerRow),
                bytesPerImage: Int(transfer.bytesPerImage)
            )
        }
        return true
    }

    public func readRegion(
        destination: UnsafeMutableRawPointer,
        transfer: TextureTransferDescriptor
    ) -> Bool {
        guard isCPUVisibleTexture,
              textureTransferFits(native, descriptor: transfer),
              let region = metalRegion(transfer.region) else {
            return false
        }

        if native.textureType == .type1D {
            native.getBytes(
                destination,
                bytesPerRow: Int(transfer.bytesPerRow),
                from: MTLRegionMake1D(
                    Int(transfer.region.origin.width),
                    Int(transfer.region.size.width)
                ),
                mipmapLevel: Int(transfer.region.mipLevel)
            )
        } else {
            native.getBytes(
                destination,
                bytesPerRow: Int(transfer.bytesPerRow),
                bytesPerImage: Int(transfer.bytesPerImage),
                from: region,
                mipmapLevel: Int(transfer.region.mipLevel),
                slice: Int(transfer.region.slice)
            )
        }
        return true
    }

    public var isCPUVisibleTexture: Bool {
        storageMode == .shared || storageMode == .managed
    }

    public var isShared: Bool {
        storageMode == .shared
    }

    public var isManaged: Bool {
        storageMode == .managed
    }

    public var isPrivate: Bool {
        storageMode == .gpuPrivate
    }

    public var isMemoryless: Bool {
        storageMode == .memoryless
    }

    public func validateRegion(_ region: TextureRegion) -> Bool {
        textureRegionFits(native, region: region)
    }

    public func validateTransfer(
        _ descriptor: TextureTransferDescriptor
    ) -> Bool {
        textureTransferFits(native, descriptor: descriptor)
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

    /// Wraps an application-owned MTLTexture handle after validating that it
    /// belongs to this device. The wrapper retains the Metal resource; the
    /// raw handle is borrowed only for the duration of this call.
    public func wrapTexture(
        nativeHandle: UnsafeMutableRawPointer,
        usage: UInt32,
        label: String = ""
    ) -> Texture? {
        let object = Unmanaged<AnyObject>
            .fromOpaque(nativeHandle)
            .takeUnretainedValue()
        guard let texture = object as? MTLTexture,
              texture.device.registryID == native.registryID else {
            return nil
        }
        if !label.isEmpty {
            texture.label = label
        }
        return Texture(native: texture, usage: usage)
    }

    /// Wraps an application-owned MTLBuffer handle after validating that it
    /// belongs to this device. The wrapper retains the Metal resource; the
    /// raw handle is borrowed only for the duration of this call.
    public func wrapBuffer(
        nativeHandle: UnsafeMutableRawPointer,
        usage: UInt32,
        label: String = ""
    ) -> Buffer? {
        let object = Unmanaged<AnyObject>
            .fromOpaque(nativeHandle)
            .takeUnretainedValue()
        guard let buffer = object as? MTLBuffer,
              buffer.device.registryID == native.registryID else {
            return nil
        }
        if !label.isEmpty {
            buffer.label = label
        }
        return Buffer(native: buffer, usage: usage)
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
    private var retainedResources: [AnyObject] = []

    fileprivate init(native: MTLCommandBuffer) {
        self.native = native
        native.addCompletedHandler { [weak self] commandBuffer in
            self?.completionErrorDescriptionStorage =
                commandBuffer.error?.localizedDescription ?? ""
            self?.retainedResources.removeAll()
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

    public var isComplete: Bool {
        status == .completed || status == .error
    }

    public var didSucceed: Bool {
        status == .completed && errorDescription.isEmpty
    }

    public var completionState: ResourceCompletionState {
        switch status {
        case .notEnqueued, .enqueued, .committed:
            return .pending
        case .scheduled:
            return .scheduled
        case .completed:
            return .completed
        case .error:
            return .failed
        @unknown default:
            return .failed
        }
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

    public var gpuStartTime: Double {
        native.gpuStartTime
    }

    public var gpuEndTime: Double {
        native.gpuEndTime
    }

    public var gpuExecutionTime: Double {
        let start = native.gpuStartTime
        let end = native.gpuEndTime
        guard start > 0, end >= start else {
            return 0
        }
        return end - start
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
        if let counterSampleBuffer = descriptor.counterSampleBuffer {
            retainedResources.append(counterSampleBuffer)
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

    public func makeComputeEncoder(
        counterSampleBuffer: CounterSampleBuffer,
        startOfEncoderSampleIndex: UInt32,
        endOfEncoderSampleIndex: UInt32
    ) -> ComputeEncoder? {
        let indices = [
            startOfEncoderSampleIndex,
            endOfEncoderSampleIndex
        ]
        guard indices.allSatisfy({
            $0 == UInt32.max || $0 < counterSampleBuffer.sampleCount
        }) else {
            wrapperErrorDescriptionStorage =
                "A compute-pass counter sample index is out of range."
            return nil
        }
        guard prepareForEncoderCreation() else {
            return nil
        }
        let passDescriptor = MTLComputePassDescriptor()
        let attachment = passDescriptor.sampleBufferAttachments[0]
        attachment.sampleBuffer = counterSampleBuffer.native
        attachment.startOfEncoderSampleIndex =
            startOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(startOfEncoderSampleIndex)
        attachment.endOfEncoderSampleIndex =
            endOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(endOfEncoderSampleIndex)
        guard let encoder = native.makeComputeCommandEncoder(
            descriptor: passDescriptor
        ) else {
            wrapperErrorDescriptionStorage =
                "Metal could not create a counter-enabled compute encoder."
            return nil
        }
        retainedResources.append(counterSampleBuffer)
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

    public func makeBlitEncoder(
        counterSampleBuffer: CounterSampleBuffer,
        startOfEncoderSampleIndex: UInt32,
        endOfEncoderSampleIndex: UInt32
    ) -> BlitEncoder? {
        let indices = [
            startOfEncoderSampleIndex,
            endOfEncoderSampleIndex
        ]
        guard indices.allSatisfy({
            $0 == UInt32.max || $0 < counterSampleBuffer.sampleCount
        }) else {
            wrapperErrorDescriptionStorage =
                "A blit-pass counter sample index is out of range."
            return nil
        }
        guard prepareForEncoderCreation() else {
            return nil
        }
        let passDescriptor = MTLBlitPassDescriptor()
        let attachment = passDescriptor.sampleBufferAttachments[0]
        attachment.sampleBuffer = counterSampleBuffer.native
        attachment.startOfEncoderSampleIndex =
            startOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(startOfEncoderSampleIndex)
        attachment.endOfEncoderSampleIndex =
            endOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(endOfEncoderSampleIndex)
        guard let encoder = native.makeBlitCommandEncoder(
            descriptor: passDescriptor
        ) else {
            wrapperErrorDescriptionStorage =
                "Metal could not create a counter-enabled blit encoder."
            return nil
        }
        retainedResources.append(counterSampleBuffer)
        let wrapper = BlitEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() }
        )
        activeEncoder = wrapper
        return wrapper
    }

    public func makeAccelerationStructureEncoder()
        -> AccelerationStructureCommandEncoder? {
        guard prepareForEncoderCreation() else {
            return nil
        }
        guard let encoder = native.makeAccelerationStructureCommandEncoder()
        else {
            wrapperErrorDescriptionStorage =
                "Metal could not create an acceleration-structure encoder."
            return nil
        }
        let wrapper = AccelerationStructureCommandEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() },
            onRetain: { [weak self] resource in
                self?.retainedResources.append(resource)
            }
        )
        activeEncoder = wrapper
        return wrapper
    }

    public func makeAccelerationStructureEncoder(
        counterSampleBuffer: CounterSampleBuffer,
        startOfEncoderSampleIndex: UInt32,
        endOfEncoderSampleIndex: UInt32
    ) -> AccelerationStructureCommandEncoder? {
        let indices = [
            startOfEncoderSampleIndex,
            endOfEncoderSampleIndex
        ]
        guard indices.allSatisfy({
            $0 == UInt32.max || $0 < counterSampleBuffer.sampleCount
        }) else {
            wrapperErrorDescriptionStorage =
                "An acceleration-pass counter sample index is out of range."
            return nil
        }
        guard prepareForEncoderCreation() else {
            return nil
        }
        guard #available(macOS 13.0, *) else {
            wrapperErrorDescriptionStorage =
                "Acceleration-pass counter attachments require macOS "
                + "13 or newer."
            return nil
        }
        let passDescriptor = MTLAccelerationStructurePassDescriptor()
        let attachment = passDescriptor.sampleBufferAttachments[0]
        attachment.sampleBuffer = counterSampleBuffer.native
        attachment.startOfEncoderSampleIndex =
            startOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(startOfEncoderSampleIndex)
        attachment.endOfEncoderSampleIndex =
            endOfEncoderSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(endOfEncoderSampleIndex)
        let encoder = native.makeAccelerationStructureCommandEncoder(
            descriptor: passDescriptor
        )
        retainedResources.append(counterSampleBuffer)
        let wrapper = AccelerationStructureCommandEncoder(
            native: encoder,
            onEnd: { [weak self] in self?.encoderDidEnd() },
            onRetain: { [weak self] resource in
                self?.retainedResources.append(resource)
            }
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

    public func waitUntilCompletedSuccessfully() -> Bool {
        native.waitUntilCompleted()
        return didSucceed
    }

    public func makeCompletionToken() -> CompletionToken {
        CompletionToken(commandBuffer: self)
    }

    public func retainResource(_ buffer: Buffer) -> Bool {
        guard !didCommit else {
            return false
        }
        retainedResources.append(buffer)
        return true
    }

    public func retainResource(_ texture: Texture) -> Bool {
        guard !didCommit else {
            return false
        }
        retainedResources.append(texture)
        return true
    }

    public func retainResource(_ drawable: Drawable) -> Bool {
        guard !didCommit else {
            return false
        }
        retainedResources.append(drawable)
        return true
    }

    public func retainResource(_ counterSampleBuffer: CounterSampleBuffer)
        -> Bool {
        guard !didCommit else {
            return false
        }
        retainedResources.append(counterSampleBuffer)
        return true
    }

    public func retainResource(
        _ accelerationStructure: AccelerationStructure
    ) -> Bool {
        guard !didCommit else {
            return false
        }
        retainedResources.append(accelerationStructure)
        return true
    }

    public var retainedResourceCount: UInt32 {
        UInt32(min(retainedResources.count, Int(UInt32.max)))
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

public final class CompletionToken {
    private let commandBuffer: CommandBuffer

    fileprivate init(commandBuffer: CommandBuffer) {
        self.commandBuffer = commandBuffer
    }

    public var status: CommandBufferStatus {
        commandBuffer.status
    }

    public var state: ResourceCompletionState {
        commandBuffer.completionState
    }

    public var isComplete: Bool {
        commandBuffer.isComplete
    }

    public var didSucceed: Bool {
        commandBuffer.didSucceed
    }

    public var errorDescription: String {
        commandBuffer.errorDescription
    }

    public func waitUntilCompleted() {
        commandBuffer.waitUntilCompleted()
    }

    public func waitUntilCompletedSuccessfully() -> Bool {
        commandBuffer.waitUntilCompletedSuccessfully()
    }
}

public final class ResourceRetirementQueue {
    private struct Entry {
        let resource: AnyObject
        let token: CompletionToken
    }

    private var entries: [Entry] = []

    public init() {}

    public var count: UInt32 {
        UInt32(min(entries.count, Int(UInt32.max)))
    }

    public func retireBuffer(
        _ buffer: Buffer,
        after token: CompletionToken
    ) -> Bool {
        guard !token.isComplete else {
            return false
        }
        entries.append(Entry(resource: buffer, token: token))
        return true
    }

    public func retireTexture(
        _ texture: Texture,
        after token: CompletionToken
    ) -> Bool {
        guard !token.isComplete else {
            return false
        }
        entries.append(Entry(resource: texture, token: token))
        return true
    }

    public func collectCompleted() -> UInt32 {
        let originalCount = entries.count
        entries.removeAll { $0.token.isComplete }
        return UInt32(
            min(originalCount - entries.count, Int(UInt32.max))
        )
    }

    public func clear() {
        entries.removeAll()
    }
}

public final class BufferResourceSlot {
    private var currentBuffer: Buffer?
    private var versionStorage: UInt64 = 0

    public init() {}

    public var buffer: Buffer? {
        currentBuffer
    }

    public var version: UInt64 {
        versionStorage
    }

    public var versionInfo: ResourceVersion {
        ResourceVersion(
            value: versionStorage,
            label: currentBuffer?.label ?? ""
        )
    }

    public func install(_ buffer: Buffer) -> UInt64 {
        versionStorage += 1
        currentBuffer = buffer
        return versionStorage
    }

    public func installAndRetire(
        _ buffer: Buffer,
        queue: ResourceRetirementQueue,
        after token: CompletionToken
    ) -> UInt64 {
        if let currentBuffer {
            _ = queue.retireBuffer(currentBuffer, after: token)
        }
        return install(buffer)
    }

    public func removeAndRetire(
        queue: ResourceRetirementQueue,
        after token: CompletionToken
    ) -> Bool {
        guard let currentBuffer else {
            return false
        }
        guard queue.retireBuffer(currentBuffer, after: token) else {
            return false
        }
        currentBuffer = nil
        versionStorage += 1
        return true
    }
}

public final class TextureResourceSlot {
    private var currentTexture: Texture?
    private var versionStorage: UInt64 = 0

    public init() {}

    public var texture: Texture? {
        currentTexture
    }

    public var version: UInt64 {
        versionStorage
    }

    public var versionInfo: ResourceVersion {
        ResourceVersion(
            value: versionStorage,
            label: currentTexture?.label ?? ""
        )
    }

    public func install(_ texture: Texture) -> UInt64 {
        versionStorage += 1
        currentTexture = texture
        return versionStorage
    }

    public func installAndRetire(
        _ texture: Texture,
        queue: ResourceRetirementQueue,
        after token: CompletionToken
    ) -> UInt64 {
        if let currentTexture {
            _ = queue.retireTexture(currentTexture, after: token)
        }
        return install(texture)
    }

    public func removeAndRetire(
        queue: ResourceRetirementQueue,
        after token: CompletionToken
    ) -> Bool {
        guard let currentTexture else {
            return false
        }
        guard queue.retireTexture(currentTexture, after: token) else {
            return false
        }
        currentTexture = nil
        versionStorage += 1
        return true
    }
}

public final class ResourceRegistry {
    private var buffers: [String: Buffer] = [:]
    private var textures: [String: Texture] = [:]

    public init() {}

    public var isThreadSafe: Bool {
        false
    }

    public var bufferCount: UInt32 {
        UInt32(min(buffers.count, Int(UInt32.max)))
    }

    public var textureCount: UInt32 {
        UInt32(min(textures.count, Int(UInt32.max)))
    }

    public func registerBuffer(
        name: String,
        buffer: Buffer
    ) -> Bool {
        guard !name.isEmpty, buffers[name] == nil else {
            return false
        }
        buffers[name] = buffer
        return true
    }

    public func registerTexture(
        name: String,
        texture: Texture
    ) -> Bool {
        guard !name.isEmpty, textures[name] == nil else {
            return false
        }
        textures[name] = texture
        return true
    }

    public func buffer(named name: String) -> Buffer? {
        buffers[name]
    }

    public func texture(named name: String) -> Texture? {
        textures[name]
    }

    public func removeBuffer(named name: String) -> Bool {
        buffers.removeValue(forKey: name) != nil
    }

    public func removeTexture(named name: String) -> Bool {
        textures.removeValue(forKey: name) != nil
    }

    public func removeAll() {
        buffers.removeAll()
        textures.removeAll()
    }
}

public final class RenderPassDescriptor {
    fileprivate let nativeDescriptor: MTLRenderPassDescriptor
    private var colorTexture: MTLTexture
    private var validationErrorStorage = ""
    private var labelStorage = ""
    private var counterSampleBufferStorage: CounterSampleBuffer?

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

    public func setColorAttachment(
        _ texture: Texture,
        index: UInt32
    ) -> Bool {
        guard index < 8, texture.pixelFormat.isColorFormat else {
            validationErrorStorage =
                "Color attachment index or format is invalid."
            return false
        }
        let attachment = nativeDescriptor.colorAttachments[Int(index)]
        attachment.texture = texture.native
        if index == 0 {
            colorTexture = texture.native
        }
        validationErrorStorage = ""
        return true
    }

    public func clearColorAttachment(index: UInt32) -> Bool {
        guard index < 8 else {
            return false
        }
        guard index != 0 else {
            validationErrorStorage =
                "The primary color attachment cannot be cleared."
            return false
        }
        nativeDescriptor.colorAttachments[Int(index)].texture = nil
        return true
    }

    public func configureColorAttachment(
        index: UInt32,
        loadAction: RenderLoadAction,
        storeAction: RenderStoreAction,
        clearColor: ClearColor
    ) -> Bool {
        guard index < 8,
              nativeDescriptor.colorAttachments[Int(index)].texture != nil,
              [
                  clearColor.red,
                  clearColor.green,
                  clearColor.blue,
                  clearColor.alpha
              ].allSatisfy({ $0.isFinite }) else {
            validationErrorStorage =
                "The color attachment configuration is invalid."
            return false
        }
        let attachment = nativeDescriptor.colorAttachments[Int(index)]
        attachment.loadAction = loadAction.metalLoadAction
        attachment.storeAction = storeAction.metalStoreAction
        attachment.clearColor = MTLClearColor(
            red: clearColor.red,
            green: clearColor.green,
            blue: clearColor.blue,
            alpha: clearColor.alpha
        )
        validationErrorStorage = ""
        return true
    }

    public func colorFormat(at index: UInt32) -> PixelFormat? {
        guard index < 8,
              let texture = nativeDescriptor.colorAttachments[Int(index)]
                  .texture else {
            return nil
        }
        return PixelFormat(metalFormat: texture.pixelFormat)
    }

    public var colorAttachmentCount: UInt32 {
        UInt32(
            (0..<8).filter {
                nativeDescriptor.colorAttachments[$0].texture != nil
            }.count
        )
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

    public var imageblockSampleLength: UInt32 {
        get { UInt32(nativeDescriptor.imageblockSampleLength) }
        set {
            nativeDescriptor.imageblockSampleLength = Int(
                min(UInt64(newValue), UInt64(Int.max))
            )
        }
    }

    public var threadgroupMemoryLength: UInt32 {
        get { UInt32(nativeDescriptor.threadgroupMemoryLength) }
        set {
            nativeDescriptor.threadgroupMemoryLength = Int(
                min(UInt64(newValue), UInt64(Int.max))
            )
        }
    }

    public var tileWidth: UInt32 {
        get { UInt32(nativeDescriptor.tileWidth) }
        set {
            nativeDescriptor.tileWidth = Int(
                min(UInt64(newValue), UInt64(Int.max))
            )
        }
    }

    public var tileHeight: UInt32 {
        get { UInt32(nativeDescriptor.tileHeight) }
        set {
            nativeDescriptor.tileHeight = Int(
                min(UInt64(newValue), UInt64(Int.max))
            )
        }
    }

    public var hasCounterSampleBuffer: Bool {
        counterSampleBufferStorage != nil
    }

    fileprivate var counterSampleBuffer: CounterSampleBuffer? {
        counterSampleBufferStorage
    }

    public func setCounterSampleBuffer(
        _ sampleBuffer: CounterSampleBuffer,
        startOfVertexSampleIndex: UInt32,
        endOfVertexSampleIndex: UInt32,
        startOfFragmentSampleIndex: UInt32,
        endOfFragmentSampleIndex: UInt32
    ) -> Bool {
        let indices = [
            startOfVertexSampleIndex,
            endOfVertexSampleIndex,
            startOfFragmentSampleIndex,
            endOfFragmentSampleIndex
        ]
        guard indices.allSatisfy({
            $0 == UInt32.max || $0 < sampleBuffer.sampleCount
        }) else {
            validationErrorStorage =
                "A render-pass counter sample index is out of range."
            return false
        }
        let attachment = nativeDescriptor.sampleBufferAttachments[0]
        attachment.sampleBuffer = sampleBuffer.native
        attachment.startOfVertexSampleIndex =
            startOfVertexSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(startOfVertexSampleIndex)
        attachment.endOfVertexSampleIndex =
            endOfVertexSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(endOfVertexSampleIndex)
        attachment.startOfFragmentSampleIndex =
            startOfFragmentSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(startOfFragmentSampleIndex)
        attachment.endOfFragmentSampleIndex =
            endOfFragmentSampleIndex == UInt32.max
                ? Int(MTLCounterDontSample)
                : Int(endOfFragmentSampleIndex)
        counterSampleBufferStorage = sampleBuffer
        validationErrorStorage = ""
        return true
    }

    public func clearCounterSampleBuffer() {
        nativeDescriptor.sampleBufferAttachments[0].sampleBuffer = nil
        counterSampleBufferStorage = nil
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

        for index in 1..<8 {
            guard let texture =
                    nativeDescriptor.colorAttachments[index].texture else {
                continue
            }
            let attachment = nativeDescriptor.colorAttachments[index]
            let format = PixelFormat(metalFormat: texture.pixelFormat)
            guard format.isColorFormat,
                  texture.sampleCount == sampleCount,
                  attachment.storeAction != .multisampleResolve else {
                validationErrorStorage =
                    "An additional color attachment is invalid."
                return false
            }
            if attachment.loadAction == .clear {
                let clear = attachment.clearColor
                guard [
                    clear.red,
                    clear.green,
                    clear.blue,
                    clear.alpha
                ].allSatisfy({ $0.isFinite }) else {
                    validationErrorStorage =
                        "An additional color clear value is invalid."
                    return false
                }
            }
            if texture.storageMode == .memoryless {
                guard attachment.loadAction != .load,
                      attachment.storeAction != .store,
                      attachment.storeAction != .multisampleResolve else {
                    validationErrorStorage =
                        "Memoryless color attachments cannot be loaded "
                        + "or stored."
                    return false
                }
            }
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

        guard (tileWidth == 0) == (tileHeight == 0) else {
            validationErrorStorage =
                "Tile and imageblock render-pass dimensions are invalid."
            return false
        }

        let colorAttachment = nativeDescriptor.colorAttachments[0]
        if colorTexture.storageMode == .memoryless {
            guard colorAttachment.loadAction != .load,
                  colorAttachment.storeAction != .store else {
                validationErrorStorage =
                    "Memoryless color attachments cannot load or store "
                    + "persistent contents."
                return false
            }
            if colorAttachment.storeAction == .multisampleResolve {
                guard let resolveTexture = colorAttachment.resolveTexture,
                      resolveTexture.storageMode != .memoryless else {
                    validationErrorStorage =
                        "A memoryless resolve must target persistent "
                        + "texture storage."
                    return false
                }
            }
        }

        if let depthTexture = nativeDescriptor.depthAttachment.texture,
           depthTexture.storageMode == .memoryless {
            guard nativeDescriptor.depthAttachment.loadAction != .load,
                  nativeDescriptor.depthAttachment.storeAction != .store,
                  nativeDescriptor.depthAttachment.storeAction
                    != .multisampleResolve else {
                validationErrorStorage =
                    "Memoryless depth attachments cannot be loaded or "
                    + "stored."
                return false
            }
        }

        if let stencilTexture = nativeDescriptor.stencilAttachment.texture,
           stencilTexture.storageMode == .memoryless {
            guard nativeDescriptor.stencilAttachment.loadAction != .load,
                  nativeDescriptor.stencilAttachment.storeAction != .store,
                  nativeDescriptor.stencilAttachment.storeAction
                    != .multisampleResolve else {
                validationErrorStorage =
                    "Memoryless stencil attachments cannot be loaded or "
                    + "stored."
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

    public func insertDebugSignpost(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.insertDebugSignpost(name)
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

    public func sampleCounters(
        _ sampleBuffer: CounterSampleBuffer,
        sampleIndex: UInt32,
        barrier: Bool
    ) -> Bool {
        guard !ended,
              sampleIndex < sampleBuffer.sampleCount,
              UInt64(sampleIndex) <= UInt64(Int.max) else {
            return false
        }
        native.sampleCounters(
            sampleBuffer: sampleBuffer.native,
            sampleIndex: Int(sampleIndex),
            barrier: barrier
        )
        return true
    }

    public func setRenderPipeline(_ pipeline: RenderPipeline) -> Bool {
        guard !ended else {
            return false
        }
        native.setRenderPipelineState(pipeline.native)
        native.setCullMode(pipeline.cullMode.metalMode)
        native.setFrontFacing(pipeline.frontFacingWinding.metalWinding)
        return true
    }

    public func setDepthStencilState(_ state: DepthStencilState?) -> Bool {
        guard !ended else {
            return false
        }
        native.setDepthStencilState(state?.native)
        return true
    }

    public func setViewport(_ extent: Extent) -> Bool {
        guard !ended, extent.width > 0, extent.height > 0 else {
            return false
        }
        native.setViewport(
            MTLViewport(
                originX: 0,
                originY: 0,
                width: Double(extent.width),
                height: Double(extent.height),
                znear: 0,
                zfar: 1
            )
        )
        return true
    }

    public func drawPrimitives(
        primitiveType: PrimitiveType,
        vertexStart: UInt32,
        vertexCount: UInt32,
        instanceCount: UInt32,
        baseInstance: UInt32
    ) -> Bool {
        guard !ended,
              vertexCount > 0,
              instanceCount > 0,
              UInt64(vertexStart) <= UInt64(Int.max),
              UInt64(vertexCount) <= UInt64(Int.max),
              UInt64(instanceCount) <= UInt64(Int.max),
              UInt64(baseInstance) <= UInt64(Int.max) else {
            return false
        }
        native.drawPrimitives(
            type: primitiveType.metalPrimitiveType,
            vertexStart: Int(vertexStart),
            vertexCount: Int(vertexCount),
            instanceCount: Int(instanceCount),
            baseInstance: Int(baseInstance)
        )
        return true
    }

    public func drawIndexedPrimitives(
        primitiveType: PrimitiveType,
        indexType: IndexType,
        indexBuffer: Buffer,
        indexBufferOffset: UInt64,
        indexCount: UInt32,
        instanceCount: UInt32,
        baseVertex: Int32,
        baseInstance: UInt32
    ) -> Bool {
        let indexStride: UInt64 = indexType == .uint16 ? 2 : 4
        guard !ended,
              indexCount > 0,
              instanceCount > 0,
              indexCount <= UInt32.max / UInt32(indexStride),
              rangeFits(
                  length: indexBuffer.length,
                  offset: indexBufferOffset,
                  count: UInt64(indexCount) * indexStride
              ),
              UInt64(indexBufferOffset) <= UInt64(Int.max),
              UInt64(indexCount) <= UInt64(Int.max),
              UInt64(instanceCount) <= UInt64(Int.max),
              UInt64(baseInstance) <= UInt64(Int.max) else {
            return false
        }
        native.drawIndexedPrimitives(
            type: primitiveType.metalPrimitiveType,
            indexType: indexType.metalIndexType,
            indexBuffer: indexBuffer.native,
            indexBufferOffset: Int(indexBufferOffset),
            indexCount: Int(indexCount),
            instanceCount: Int(instanceCount),
            baseVertex: Int(baseVertex),
            baseInstance: Int(baseInstance)
        )
        return true
    }

    public func drawMeshThreadgroups(
        _ descriptor: MeshDispatchDescriptor
    ) -> Bool {
        guard !ended,
              let threadgroups = metalSize(descriptor.threadgroups),
              let objectThreads = metalSize(
                  descriptor.threadsPerObjectGroup
              ),
              let meshThreads = metalSize(descriptor.threadsPerMeshGroup)
        else {
            return false
        }
        native.drawMeshThreadgroups(
            threadgroups,
            threadsPerObjectThreadgroup: objectThreads,
            threadsPerMeshThreadgroup: meshThreads
        )
        return true
    }

    public func setObjectBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setObjectBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setMeshBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setMeshBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setTilePipeline(_ pipeline: TilePipeline) -> Bool {
        guard !ended else {
            return false
        }
        native.setTileRenderPipelineState(pipeline.native)
        return true
    }

    public func setTileBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setTileBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setTileTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setTileTexture(texture.native, index: Int(index))
        return true
    }

    public func setTileSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setTileSamplerState(sampler.native, index: Int(index))
        return true
    }

    public func setTileBytes(
        _ parameters: ParameterBlock,
        index: UInt32
    ) -> Bool {
        guard !ended,
              parameters.length <= 4096,
              UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        return parameters.withUnsafeBytes { pointer, length in
            native.setTileBytes(pointer, length: length, index: Int(index))
        }
    }

    public func dispatchThreadsPerTile(_ threads: Extent3D) -> Bool {
        guard !ended, let threadsPerTile = metalSize(threads) else {
            return false
        }
        native.dispatchThreadsPerTile(threadsPerTile)
        return true
    }

    public func setVertexArgumentBuffer(
        _ argumentBuffer: ArgumentBuffer,
        index: UInt32
    ) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexBuffer(
            argumentBuffer.nativeBuffer,
            offset: 0,
            index: Int(index)
        )
        return true
    }

    public func setFragmentArgumentBuffer(
        _ argumentBuffer: ArgumentBuffer,
        index: UInt32
    ) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentBuffer(
            argumentBuffer.nativeBuffer,
            offset: 0,
            index: Int(index)
        )
        return true
    }

    public func executeIndirectCommands(
        _ commands: IndirectCommandBuffer,
        rangeStart: UInt32,
        count: UInt32
    ) -> Bool {
        guard !ended, commands.rangeIsValid(start: rangeStart, count: count),
              UInt64(rangeStart) <= UInt64(Int.max),
              UInt64(count) <= UInt64(Int.max) else {
            return false
        }
        native.executeCommandsInBuffer(
            commands.native,
            with: NSRange(
                location: Int(rangeStart),
                length: Int(count)
            )
        )
        return true
    }

    public func setVertexBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setFragmentBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setVertexTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexTexture(texture.native, index: Int(index))
        return true
    }

    public func setFragmentTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentTexture(texture.native, index: Int(index))
        return true
    }

    public func setVertexSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexSamplerState(sampler.native, index: Int(index))
        return true
    }

    public func setFragmentSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentSamplerState(sampler.native, index: Int(index))
        return true
    }

    public func setVertexBytes(
        _ parameters: ParameterBlock,
        index: UInt32
    ) -> Bool {
        guard !ended,
              parameters.length <= 4096,
              UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        return parameters.withUnsafeBytes { pointer, length in
            native.setVertexBytes(pointer, length: length, index: Int(index))
        }
    }

    public func setFragmentBytes(
        _ parameters: ParameterBlock,
        index: UInt32
    ) -> Bool {
        guard !ended,
              parameters.length <= 4096,
              UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        return parameters.withUnsafeBytes { pointer, length in
            native.setFragmentBytes(pointer, length: length, index: Int(index))
        }
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

    public func insertDebugSignpost(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.insertDebugSignpost(name)
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

    public func sampleCounters(
        _ sampleBuffer: CounterSampleBuffer,
        sampleIndex: UInt32,
        barrier: Bool
    ) -> Bool {
        guard !ended,
              sampleIndex < sampleBuffer.sampleCount,
              UInt64(sampleIndex) <= UInt64(Int.max) else {
            return false
        }
        native.sampleCounters(
            sampleBuffer: sampleBuffer.native,
            sampleIndex: Int(sampleIndex),
            barrier: barrier
        )
        return true
    }

    public func setComputePipeline(_ pipeline: ComputePipeline) -> Bool {
        guard !ended else {
            return false
        }
        native.setComputePipelineState(pipeline.native)
        return true
    }

    public func setBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setTexture(texture.native, index: Int(index))
        return true
    }

    public func setAccelerationStructure(
        _ accelerationStructure: AccelerationStructure,
        index: UInt32
    ) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setAccelerationStructure(
            accelerationStructure.native,
            bufferIndex: Int(index)
        )
        return true
    }

    public func setIntersectionFunctionTable(
        _ table: IntersectionFunctionTable,
        index: UInt32
    ) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setIntersectionFunctionTable(
            table.native,
            bufferIndex: Int(index)
        )
        return true
    }

    public func setSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setSamplerState(sampler.native, index: Int(index))
        return true
    }

    public func setBytes(
        _ parameters: ParameterBlock,
        index: UInt32
    ) -> Bool {
        guard !ended,
              parameters.length <= 4096,
              UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        return parameters.withUnsafeBytes { pointer, length in
            native.setBytes(pointer, length: length, index: Int(index))
        }
    }

    public func setArgumentBuffer(
        _ argumentBuffer: ArgumentBuffer,
        index: UInt32
    ) -> Bool {
        guard !ended, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setBuffer(
            argumentBuffer.nativeBuffer,
            offset: 0,
            index: Int(index)
        )
        return true
    }

    public func dispatchThreadgroups(
        _ threadgroups: Extent3D,
        threadsPerThreadgroup: Extent3D
    ) -> Bool {
        guard !ended,
              let groups = metalSize(threadgroups),
              let threads = metalSize(threadsPerThreadgroup) else {
            return false
        }
        native.dispatchThreadgroups(
            groups,
            threadsPerThreadgroup: threads
        )
        return true
    }

    public func dispatchThreads(
        _ threads: Extent3D,
        threadsPerThreadgroup: Extent3D
    ) -> Bool {
        guard !ended,
              let grid = metalSize(threads),
              let threadgroup = metalSize(threadsPerThreadgroup) else {
            return false
        }
        native.dispatchThreads(
            grid,
            threadsPerThreadgroup: threadgroup
        )
        return true
    }

    public func executeIndirectCommands(
        _ commands: IndirectCommandBuffer,
        rangeStart: UInt32,
        count: UInt32
    ) -> Bool {
        guard !ended, commands.rangeIsValid(start: rangeStart, count: count),
              UInt64(rangeStart) <= UInt64(Int.max),
              UInt64(count) <= UInt64(Int.max) else {
            return false
        }
        native.executeCommandsInBuffer(
            commands.native,
            with: NSRange(
                location: Int(rangeStart),
                length: Int(count)
            )
        )
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
    private var errorDescriptionStorage = ""

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

    public var errorDescription: String {
        errorDescriptionStorage
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

    public func insertDebugSignpost(_ name: String) -> Bool {
        guard !ended else {
            return false
        }
        native.insertDebugSignpost(name)
        return true
    }

    public func sampleCounters(
        _ sampleBuffer: CounterSampleBuffer,
        sampleIndex: UInt32,
        barrier: Bool
    ) -> Bool {
        guard !ended,
              sampleIndex < sampleBuffer.sampleCount,
              UInt64(sampleIndex) <= UInt64(Int.max) else {
            return false
        }
        native.sampleCounters(
            sampleBuffer: sampleBuffer.native,
            sampleIndex: Int(sampleIndex),
            barrier: barrier
        )
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

    public func copyBufferRange(
        source: Buffer,
        sourceRange: BufferRange,
        destination: Buffer,
        destinationOffset: UInt64
    ) -> Bool {
        guard source.validateRange(sourceRange),
              rangeFits(
                  length: destination.length,
                  offset: destinationOffset,
                  count: sourceRange.length
              ) else {
            errorDescriptionStorage =
                "The buffer copy range is outside the source or destination."
            return false
        }
        return copyBuffer(
            source: source,
            sourceOffset: sourceRange.offset,
            destination: destination,
            destinationOffset: destinationOffset,
            length: sourceRange.length
        )
    }

    public func copyTextureRegion(
        source: Texture,
        sourceRegion: TextureRegion,
        destination: Texture,
        destinationRegion: TextureRegion
    ) -> Bool {
        guard !ended,
              source.pixelFormat == destination.pixelFormat,
              sourceRegion.size.width == destinationRegion.size.width,
              sourceRegion.size.height == destinationRegion.size.height,
              sourceRegion.size.depth == destinationRegion.size.depth,
              source.validateRegion(sourceRegion),
              destination.validateRegion(destinationRegion),
              let sourceOrigin = metalSize(sourceRegion.origin),
              let sourceSize = metalSize(sourceRegion.size),
              let destinationOrigin = metalSize(destinationRegion.origin)
        else {
            errorDescriptionStorage =
                "The texture copy regions are incompatible or invalid."
            return false
        }
        native.copy(
            from: source.native,
            sourceSlice: Int(sourceRegion.slice),
            sourceLevel: Int(sourceRegion.mipLevel),
            sourceOrigin: MTLOrigin(
                x: sourceOrigin.width,
                y: sourceOrigin.height,
                z: sourceOrigin.depth
            ),
            sourceSize: sourceSize,
            to: destination.native,
            destinationSlice: Int(destinationRegion.slice),
            destinationLevel: Int(destinationRegion.mipLevel),
            destinationOrigin: MTLOrigin(
                x: destinationOrigin.width,
                y: destinationOrigin.height,
                z: destinationOrigin.depth
            )
        )
        return true
    }

    public func copyBufferToTexture(
        source: Buffer,
        sourceOffset: UInt64,
        bytesPerRow: UInt64,
        bytesPerImage: UInt64,
        destination: Texture,
        destinationRegion: TextureRegion
    ) -> Bool {
        let transfer = TextureTransferDescriptor(
            region: destinationRegion,
            bytesPerRow: bytesPerRow,
            bytesPerImage: bytesPerImage
        )
        guard !ended,
              let byteCount = textureTransferByteCount(
                  destination,
                  descriptor: transfer
              ),
              source.validateRange(
                  BufferRange(offset: sourceOffset, length: byteCount)
              ),
              let sourceSize = metalSize(destinationRegion.size),
              let destinationOrigin = metalSize(destinationRegion.origin)
        else {
            errorDescriptionStorage =
                "The buffer-to-texture transfer descriptor is invalid."
            return false
        }
        native.copy(
            from: source.native,
            sourceOffset: Int(sourceOffset),
            sourceBytesPerRow: Int(bytesPerRow),
            sourceBytesPerImage: Int(bytesPerImage),
            sourceSize: sourceSize,
            to: destination.native,
            destinationSlice: Int(destinationRegion.slice),
            destinationLevel: Int(destinationRegion.mipLevel),
            destinationOrigin: MTLOrigin(
                x: destinationOrigin.width,
                y: destinationOrigin.height,
                z: destinationOrigin.depth
            )
        )
        return true
    }

    public func copyTextureToBuffer(
        source: Texture,
        sourceRegion: TextureRegion,
        destination: Buffer,
        destinationOffset: UInt64,
        bytesPerRow: UInt64,
        bytesPerImage: UInt64
    ) -> Bool {
        let transfer = TextureTransferDescriptor(
            region: sourceRegion,
            bytesPerRow: bytesPerRow,
            bytesPerImage: bytesPerImage
        )
        guard !ended,
              let byteCount = textureTransferByteCount(
                  source,
                  descriptor: transfer
              ),
              destination.validateRange(
                  BufferRange(offset: destinationOffset, length: byteCount)
              ),
              let sourceOrigin = metalSize(sourceRegion.origin),
              let sourceSize = metalSize(sourceRegion.size)
        else {
            errorDescriptionStorage =
                "The texture-to-buffer transfer descriptor is invalid."
            return false
        }
        native.copy(
            from: source.native,
            sourceSlice: Int(sourceRegion.slice),
            sourceLevel: Int(sourceRegion.mipLevel),
            sourceOrigin: MTLOrigin(
                x: sourceOrigin.width,
                y: sourceOrigin.height,
                z: sourceOrigin.depth
            ),
            sourceSize: sourceSize,
            to: destination.native,
            destinationOffset: Int(destinationOffset),
            destinationBytesPerRow: Int(bytesPerRow),
            destinationBytesPerImage: Int(bytesPerImage)
        )
        return true
    }

    public func copyDrawableToBuffer(
        source: Drawable,
        transfer: TextureTransferDescriptor,
        destination: Buffer,
        destinationOffset: UInt64
    ) -> Bool {
        guard !ended,
              textureTransferFits(source.texture, descriptor: transfer),
              let byteCount = textureTransferByteCount(
                  source.texture,
                  descriptor: transfer
              ),
              destination.validateRange(
                  BufferRange(offset: destinationOffset, length: byteCount)
              ),
              let sourceOrigin = metalSize(transfer.region.origin),
              let sourceSize = metalSize(transfer.region.size)
        else {
            errorDescriptionStorage =
                "The drawable readback descriptor is invalid."
            return false
        }
        native.copy(
            from: source.texture,
            sourceSlice: Int(transfer.region.slice),
            sourceLevel: Int(transfer.region.mipLevel),
            sourceOrigin: MTLOrigin(
                x: sourceOrigin.width,
                y: sourceOrigin.height,
                z: sourceOrigin.depth
            ),
            sourceSize: sourceSize,
            to: destination.native,
            destinationOffset: Int(destinationOffset),
            destinationBytesPerRow: Int(transfer.bytesPerRow),
            destinationBytesPerImage: Int(transfer.bytesPerImage)
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

    public func synchronize(
        _ buffer: Buffer,
        direction: ResourceSyncDirection
    ) -> Bool {
        guard !ended else {
            return false
        }
        switch direction {
        case .cpuToGPU:
            return buffer.synchronizeForCPUToGPU(
                range: BufferRange(offset: 0, length: buffer.length)
            )
        case .gpuToCPU:
            guard buffer.storageMode == .managed else {
                return false
            }
            native.synchronize(resource: buffer.native)
            return true
        }
    }

    public func synchronize(_ texture: Texture) -> Bool {
        guard !ended, texture.storageMode == .managed else {
            return false
        }
        native.synchronize(resource: texture.native)
        return true
    }

    public func synchronize(
        _ texture: Texture,
        direction: ResourceSyncDirection
    ) -> Bool {
        guard !ended else {
            return false
        }
        switch direction {
        case .cpuToGPU:
            guard texture.storageMode == .managed else {
                return false
            }
            return true
        case .gpuToCPU:
            guard texture.storageMode == .managed else {
                return false
            }
            native.synchronize(resource: texture.native)
            return true
        }
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

public final class AccelerationStructureCommandEncoder {
    private let native: MTLAccelerationStructureCommandEncoder
    private let onEnd: () -> Void
    private let onRetain: (AnyObject) -> Void
    private var ended = false
    private var errorDescriptionStorage = ""

    fileprivate init(
        native: MTLAccelerationStructureCommandEncoder,
        onEnd: @escaping () -> Void,
        onRetain: @escaping (AnyObject) -> Void
    ) {
        self.native = native
        self.onEnd = onEnd
        self.onRetain = onRetain
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public var isEnded: Bool {
        ended
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func buildPrimitive(
        accelerationStructure: AccelerationStructure,
        descriptor: PrimitiveAccelerationStructureDescriptor,
        scratchBuffer: Buffer,
        scratchBufferOffset: UInt64
    ) -> Bool {
        guard !ended,
              let nativeDescriptor = descriptor.makeMetalDescriptor(),
              rangeFits(
                  length: scratchBuffer.length,
                  offset: scratchBufferOffset,
                  count: accelerationStructure.sizes.buildScratchBufferSize
              ) else {
            errorDescriptionStorage =
                descriptor.validationError.isEmpty
                    ? "The primitive acceleration-structure build is invalid."
                    : descriptor.validationError
            return false
        }
        native.build(
            accelerationStructure: accelerationStructure.native,
            descriptor: nativeDescriptor,
            scratchBuffer: scratchBuffer.native,
            scratchBufferOffset: Int(scratchBufferOffset)
        )
        onRetain(accelerationStructure)
        onRetain(scratchBuffer)
        descriptor.referencedResources.forEach(onRetain)
        errorDescriptionStorage = ""
        return true
    }

    public func buildInstance(
        accelerationStructure: AccelerationStructure,
        descriptor: InstanceAccelerationStructureDescriptor,
        scratchBuffer: Buffer,
        scratchBufferOffset: UInt64
    ) -> Bool {
        guard !ended,
              let nativeDescriptor = descriptor.makeMetalDescriptor(),
              rangeFits(
                  length: scratchBuffer.length,
                  offset: scratchBufferOffset,
                  count: accelerationStructure.sizes.buildScratchBufferSize
              ) else {
            errorDescriptionStorage =
                descriptor.validationError.isEmpty
                    ? "The instance acceleration-structure build is invalid."
                    : descriptor.validationError
            return false
        }
        native.build(
            accelerationStructure: accelerationStructure.native,
            descriptor: nativeDescriptor,
            scratchBuffer: scratchBuffer.native,
            scratchBufferOffset: Int(scratchBufferOffset)
        )
        onRetain(accelerationStructure)
        onRetain(scratchBuffer)
        descriptor.referencedResources.forEach(onRetain)
        errorDescriptionStorage = ""
        return true
    }

    public func refitPrimitive(
        source: AccelerationStructure,
        destination: AccelerationStructure,
        descriptor: PrimitiveAccelerationStructureDescriptor,
        scratchBuffer: Buffer,
        scratchBufferOffset: UInt64
    ) -> Bool {
        guard !ended,
              let nativeDescriptor = descriptor.makeMetalDescriptor(),
              rangeFits(
                  length: scratchBuffer.length,
                  offset: scratchBufferOffset,
                  count: destination.sizes.refitScratchBufferSize
              ) else {
            errorDescriptionStorage =
                descriptor.validationError.isEmpty
                    ? "The primitive acceleration-structure refit is invalid."
                    : descriptor.validationError
            return false
        }
        native.refit(
            sourceAccelerationStructure: source.native,
            descriptor: nativeDescriptor,
            destinationAccelerationStructure: destination.native,
            scratchBuffer: scratchBuffer.native,
            scratchBufferOffset: Int(scratchBufferOffset)
        )
        onRetain(source)
        onRetain(destination)
        onRetain(scratchBuffer)
        descriptor.referencedResources.forEach(onRetain)
        errorDescriptionStorage = ""
        return true
    }

    public func refitInstance(
        source: AccelerationStructure,
        destination: AccelerationStructure,
        descriptor: InstanceAccelerationStructureDescriptor,
        scratchBuffer: Buffer,
        scratchBufferOffset: UInt64
    ) -> Bool {
        guard !ended,
              let nativeDescriptor = descriptor.makeMetalDescriptor(),
              rangeFits(
                  length: scratchBuffer.length,
                  offset: scratchBufferOffset,
                  count: destination.sizes.refitScratchBufferSize
              ) else {
            errorDescriptionStorage =
                descriptor.validationError.isEmpty
                    ? "The instance acceleration-structure refit is invalid."
                    : descriptor.validationError
            return false
        }
        native.refit(
            sourceAccelerationStructure: source.native,
            descriptor: nativeDescriptor,
            destinationAccelerationStructure: destination.native,
            scratchBuffer: scratchBuffer.native,
            scratchBufferOffset: Int(scratchBufferOffset)
        )
        onRetain(source)
        onRetain(destination)
        onRetain(scratchBuffer)
        descriptor.referencedResources.forEach(onRetain)
        errorDescriptionStorage = ""
        return true
    }

    public func copy(
        source: AccelerationStructure,
        destination: AccelerationStructure
    ) -> Bool {
        guard !ended else {
            return false
        }
        native.copy(
            sourceAccelerationStructure: source.native,
            destinationAccelerationStructure: destination.native
        )
        onRetain(source)
        onRetain(destination)
        return true
    }

    public func copyAndCompact(
        source: AccelerationStructure,
        destination: AccelerationStructure
    ) -> Bool {
        guard !ended else {
            return false
        }
        native.copyAndCompact(
            sourceAccelerationStructure: source.native,
            destinationAccelerationStructure: destination.native
        )
        onRetain(source)
        onRetain(destination)
        return true
    }

    public func writeCompactedSize(
        accelerationStructure: AccelerationStructure,
        buffer: Buffer,
        offset: UInt64
    ) -> Bool {
        guard !ended,
              rangeFits(length: buffer.length, offset: offset, count: 8),
              offset <= UInt64(Int.max) else {
            return false
        }
        native.writeCompactedSize(
            accelerationStructure: accelerationStructure.native,
            buffer: buffer.native,
            offset: Int(offset),
            sizeDataType: .ulong
        )
        onRetain(accelerationStructure)
        onRetain(buffer)
        return true
    }

    public func sampleCounters(
        _ sampleBuffer: CounterSampleBuffer,
        sampleIndex: UInt32,
        barrier: Bool
    ) -> Bool {
        guard !ended,
              sampleIndex < sampleBuffer.sampleCount,
              UInt64(sampleIndex) <= UInt64(Int.max) else {
            return false
        }
        native.sampleCounters(
            sampleBuffer: sampleBuffer.native,
            sampleIndex: Int(sampleIndex),
            barrier: barrier
        )
        onRetain(sampleBuffer)
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

    public var storageMode: StorageMode {
        StorageMode(metalStorageMode: texture.storageMode)
    }

    public func validateRegion(_ region: TextureRegion) -> Bool {
        textureRegionFits(texture, region: region)
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

public final class FunctionConstants {
    fileprivate let native: MTLFunctionConstantValues
    private var values: [UInt32: String] = [:]

    public init() {
        self.native = MTLFunctionConstantValues()
    }

    public var signature: String {
        values.keys.sorted().map { index in
            "\(index)=\(values[index] ?? "")"
        }.joined(separator: ";")
    }

    public func setBool(_ index: UInt32, value: Bool) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var value = value
        native.setConstantValue(
            &value,
            type: FunctionConstantType.bool.metalDataType,
            index: Int(index)
        )
        values[index] = "bool:\(value ? 1 : 0)"
        return true
    }

    public func setInt32(_ index: UInt32, value: Int32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var value = value
        native.setConstantValue(
            &value,
            type: FunctionConstantType.int32.metalDataType,
            index: Int(index)
        )
        values[index] = "int32:\(value)"
        return true
    }

    public func setUInt32(_ index: UInt32, value: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var value = value
        native.setConstantValue(
            &value,
            type: FunctionConstantType.uint32.metalDataType,
            index: Int(index)
        )
        values[index] = "uint32:\(value)"
        return true
    }

    public func setFloat(_ index: UInt32, value: Float) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var value = value
        native.setConstantValue(
            &value,
            type: FunctionConstantType.float.metalDataType,
            index: Int(index)
        )
        values[index] = "float:\(value)"
        return true
    }

    public func setDouble(_ index: UInt32, value: Double) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var value = value
        native.setConstantValue(
            &value,
            type: FunctionConstantType.double.metalDataType,
            index: Int(index)
        )
        values[index] = "double:\(value)"
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native).toOpaque()
    }
}

public final class ParameterBlock {
    private var storage: [UInt8]
    public let alignment: UInt32

    public init(length: UInt32, alignment: UInt32 = 16) {
        self.storage = Array(repeating: 0, count: Int(length))
        self.alignment = max(1, alignment)
    }

    public var length: UInt32 {
        UInt32(storage.count)
    }

    public func clear() {
        storage = Array(repeating: 0, count: storage.count)
    }

    public func writeBytes(
        _ source: UnsafeRawPointer,
        length: UInt32,
        offset: UInt32
    ) -> Bool {
        guard UInt64(offset) + UInt64(length) <= UInt64(storage.count),
              UInt64(length) <= UInt64(Int.max) else {
            return false
        }
        guard length > 0 else {
            return true
        }
        storage.withUnsafeMutableBytes { destination in
            guard let destinationAddress = destination.baseAddress else {
                return
            }
            destinationAddress
                .advanced(by: Int(offset))
                .copyMemory(from: source, byteCount: Int(length))
        }
        return true
    }

    public func setUInt32(_ offset: UInt32, value: UInt32) -> Bool {
        withUnsafeBytes(of: value) {
            writeBytes($0, length: UInt32(MemoryLayout<UInt32>.size), offset: offset)
        }
    }

    public func setInt32(_ offset: UInt32, value: Int32) -> Bool {
        withUnsafeBytes(of: value) {
            writeBytes($0, length: UInt32(MemoryLayout<Int32>.size), offset: offset)
        }
    }

    public func setFloat(_ offset: UInt32, value: Float) -> Bool {
        withUnsafeBytes(of: value) {
            writeBytes($0, length: UInt32(MemoryLayout<Float>.size), offset: offset)
        }
    }

    public func setDouble(_ offset: UInt32, value: Double) -> Bool {
        withUnsafeBytes(of: value) {
            writeBytes($0, length: UInt32(MemoryLayout<Double>.size), offset: offset)
        }
    }

    fileprivate func withUnsafeBytes(
        _ body: (UnsafeRawPointer, Int) -> Void
    ) -> Bool {
        guard !storage.isEmpty else {
            return false
        }
        storage.withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return
            }
            body(baseAddress, bytes.count)
        }
        return true
    }
}

public final class ArgumentBuffer {
    private let backing: Buffer
    private let supportsNestedBuffers: Bool
    fileprivate let encoder: MTLArgumentEncoder

    fileprivate init(
        backing: Buffer,
        encoder: MTLArgumentEncoder,
        supportsNestedBuffers: Bool = false
    ) {
        self.backing = backing
        self.encoder = encoder
        self.supportsNestedBuffers = supportsNestedBuffers
        encoder.setArgumentBuffer(backing.native, offset: 0)
    }

    public var encodedLength: UInt64 {
        UInt64(encoder.encodedLength)
    }

    public var alignment: UInt64 {
        UInt64(encoder.alignment)
    }

    public var storageMode: StorageMode {
        backing.storageMode
    }

    public var label: String {
        get { backing.label }
        set { backing.label = newValue }
    }

    fileprivate var nativeBuffer: MTLBuffer {
        backing.native
    }

    public func setBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        encoder.setBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        encoder.setTexture(texture.native, index: Int(index))
        return true
    }

    public func setBuffers(
        _ buffers: [Buffer],
        offsets: [UInt64],
        index: UInt32
    ) -> Bool {
        guard !buffers.isEmpty,
              buffers.count == offsets.count,
              UInt64(index) + UInt64(buffers.count) <= UInt64(Int.max)
        else {
            return false
        }
        for (offset, buffer) in zip(offsets, buffers) {
            guard rangeFits(length: buffer.length, offset: offset, count: 0),
                  UInt64(offset) <= UInt64(Int.max) else {
                return false
            }
        }
        for (position, pair) in zip(buffers.indices, zip(buffers, offsets)) {
            encoder.setBuffer(
                pair.0.native,
                offset: Int(pair.1),
                index: Int(index) + position
            )
        }
        return true
    }

    public func setTextures(
        _ textures: [Texture],
        index: UInt32
    ) -> Bool {
        guard !textures.isEmpty,
              UInt64(index) + UInt64(textures.count) <= UInt64(Int.max)
        else {
            return false
        }
        for (position, texture) in textures.enumerated() {
            encoder.setTexture(texture.native, index: Int(index) + position)
        }
        return true
    }

    public func setSamplers(
        _ samplers: [Sampler],
        index: UInt32
    ) -> Bool {
        guard !samplers.isEmpty,
              UInt64(index) + UInt64(samplers.count) <= UInt64(Int.max)
        else {
            return false
        }
        for (position, sampler) in samplers.enumerated() {
            encoder.setSamplerState(
                sampler.native,
                index: Int(index) + position
            )
        }
        return true
    }

    public func makeNestedArgumentBuffer(
        index: UInt32,
        storageMode: StorageMode? = nil,
        label: String = ""
    ) -> ArgumentBuffer? {
        guard supportsNestedBuffers,
              UInt64(index) <= UInt64(Int.max),
              let nestedEncoder = encoder.makeArgumentEncoderForBuffer(
                  atIndex: Int(index)
              ),
              nestedEncoder.encodedLength > 0 else {
            return nil
        }
        let mode = storageMode ?? backing.storageMode
        guard mode == .shared || mode == .managed else {
            return nil
        }
        let descriptor = BufferDescriptor(
            length: UInt64(nestedEncoder.encodedLength),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: mode,
            cpuCacheMode: backing.cpuCacheMode,
            hazardMode: backing.hazardMode,
            label: label
        )
        guard let nestedNative = backing.native.device.makeBuffer(
            length: Int(descriptor.length),
            options: descriptor.metalResourceOptions
        ) else {
            return nil
        }
        let nestedBacking = Buffer(
            native: nestedNative,
            usage: descriptor.usage
        )
        nestedBacking.label = label
        return ArgumentBuffer(
            backing: nestedBacking,
            encoder: nestedEncoder,
            supportsNestedBuffers: supportsNestedBuffers
        )
    }

    public func setNestedArgumentBuffer(
        _ nested: ArgumentBuffer,
        offset: UInt64 = 0,
        index: UInt32
    ) -> Bool {
        guard nested.supportsNestedBuffers else {
            return false
        }
        return setBuffer(
            Buffer(
                native: nested.nativeBuffer,
                usage: UInt32(BufferUsage.storage.rawValue)
            ),
            offset: offset,
            index: index
        )
    }

    public func setSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        encoder.setSamplerState(sampler.native, index: Int(index))
        return true
    }

    public func setBytes(_ bytes: [UInt8], index: UInt32) -> Bool {
        guard !bytes.isEmpty, UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        var copied = false
        bytes.withUnsafeBytes { source in
            guard let baseAddress = source.baseAddress else {
                return
            }
            let destination = encoder.constantData(at: Int(index))
            destination.copyMemory(
                from: baseAddress,
                byteCount: source.count
            )
            copied = true
        }
        return copied
    }

    public func setUInt32(_ value: UInt32, index: UInt32) -> Bool {
        var value = value
        return withUnsafeBytes(of: &value) { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return false
            }
            return setBytes(
                Array(
                    UnsafeRawBufferPointer(
                        start: baseAddress,
                        count: bytes.count
                    )
                ),
                index: index
            )
        }
    }

    public func setFloat(_ value: Float, index: UInt32) -> Bool {
        var value = value
        return withUnsafeBytes(of: &value) { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return false
            }
            return setBytes(
                Array(
                    UnsafeRawBufferPointer(
                        start: baseAddress,
                        count: bytes.count
                    )
                ),
                index: index
            )
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(nativeBuffer as AnyObject).toOpaque()
    }
}

public final class ArgumentBufferTable {
    private var entries: [UInt32: ArgumentBuffer] = [:]

    public init() {}

    public var count: UInt32 {
        UInt32(entries.count)
    }

    public func setArgumentBuffer(
        _ argumentBuffer: ArgumentBuffer,
        index: UInt32
    ) -> Bool {
        entries[index] = argumentBuffer
        return true
    }

    public func argumentBuffer(_ index: UInt32) -> ArgumentBuffer? {
        entries[index]
    }

    public func removeArgumentBuffer(_ index: UInt32) -> Bool {
        entries.removeValue(forKey: index) != nil
    }

    public func removeAll() {
        entries.removeAll(keepingCapacity: true)
    }

    public func bindVertex(to encoder: RenderEncoder) -> Bool {
        for index in entries.keys.sorted() {
            guard let argumentBuffer = entries[index],
                  encoder.setVertexArgumentBuffer(
                      argumentBuffer,
                      index: index
                  ) else {
                return false
            }
        }
        return true
    }

    public func bindFragment(to encoder: RenderEncoder) -> Bool {
        for index in entries.keys.sorted() {
            guard let argumentBuffer = entries[index],
                  encoder.setFragmentArgumentBuffer(
                      argumentBuffer,
                      index: index
                  ) else {
                return false
            }
        }
        return true
    }

    public func bindCompute(to encoder: ComputeEncoder) -> Bool {
        for index in entries.keys.sorted() {
            guard let argumentBuffer = entries[index],
                  encoder.setArgumentBuffer(
                      argumentBuffer,
                      index: index
                  ) else {
                return false
            }
        }
        return true
    }
}

public final class IndirectRenderCommand {
    fileprivate let native: MTLIndirectRenderCommand

    fileprivate init(native: MTLIndirectRenderCommand) {
        self.native = native
    }

    public func setRenderPipeline(_ pipeline: RenderPipeline) {
        native.setRenderPipelineState(pipeline.native)
    }

    public func setVertexBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexBuffer(
            buffer.native,
            offset: Int(offset),
            at: Int(index)
        )
        return true
    }

    public func setFragmentBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentBuffer(
            buffer.native,
            offset: Int(offset),
            at: Int(index)
        )
        return true
    }

    public func setVertexTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setVertexTexture(texture.native, at: Int(index))
        return true
    }

    public func setFragmentTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setFragmentTexture(texture.native, at: Int(index))
        return true
    }

    public func drawPrimitives(
        primitiveType: PrimitiveType,
        vertexStart: UInt32,
        vertexCount: UInt32,
        instanceCount: UInt32,
        baseInstance: UInt32
    ) -> Bool {
        guard vertexCount > 0,
              instanceCount > 0,
              UInt64(vertexStart) <= UInt64(Int.max),
              UInt64(vertexCount) <= UInt64(Int.max),
              UInt64(instanceCount) <= UInt64(Int.max),
              UInt64(baseInstance) <= UInt64(Int.max) else {
            return false
        }
        native.drawPrimitives(
            primitiveType: primitiveType.metalPrimitiveType,
            vertexStart: Int(vertexStart),
            vertexCount: Int(vertexCount),
            instanceCount: Int(instanceCount),
            baseInstance: Int(baseInstance)
        )
        return true
    }

    public func drawIndexedPrimitives(
        indexType: IndexType,
        indexBuffer: Buffer,
        indexBufferOffset: UInt64,
        indexCount: UInt32,
        instanceCount: UInt32,
        baseVertex: Int32,
        baseInstance: UInt32
    ) -> Bool {
        guard indexCount > 0,
              instanceCount > 0,
              rangeFits(
                  length: indexBuffer.length,
                  offset: indexBufferOffset,
                  count: UInt64(indexCount)
                      * (indexType == .uint16 ? 2 : 4)
              ),
              UInt64(indexBufferOffset) <= UInt64(Int.max),
              UInt64(indexCount) <= UInt64(Int.max),
              UInt64(instanceCount) <= UInt64(Int.max),
              UInt64(baseInstance) <= UInt64(Int.max) else {
            return false
        }
        native.drawIndexedPrimitives(
            indexType: indexType.metalIndexType,
            indexBuffer: indexBuffer.native,
            indexBufferOffset: Int(indexBufferOffset),
            indexCount: Int(indexCount),
            instanceCount: Int(instanceCount),
            baseVertex: Int(baseVertex),
            baseInstance: Int(baseInstance)
        )
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class IndirectComputeCommand {
    fileprivate let native: MTLIndirectComputeCommand

    fileprivate init(native: MTLIndirectComputeCommand) {
        self.native = native
    }

    public func setComputePipeline(_ pipeline: ComputePipeline) {
        native.setComputePipelineState(pipeline.native)
    }

    public func setBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(index) <= UInt64(Int.max),
              UInt64(offset) <= UInt64(Int.max) else {
            return false
        }
        native.setKernelBuffer(
            buffer.native,
            offset: Int(offset),
            at: Int(index)
        )
        return true
    }

    public func setTexture(_ texture: Texture, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setKernelTexture(texture.native, at: Int(index))
        return true
    }

    public func setSampler(_ sampler: Sampler, index: UInt32) -> Bool {
        guard UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setKernelSamplerState(sampler.native, at: Int(index))
        return true
    }

    public func dispatchThreadgroups(
        _ threadgroups: Extent3D,
        threadsPerThreadgroup: Extent3D
    ) -> Bool {
        guard let groups = metalSize(threadgroups),
              let threads = metalSize(threadsPerThreadgroup) else {
            return false
        }
        native.concurrentDispatchThreadgroups(
            groups,
            threadsPerThreadgroup: threads
        )
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class IndirectCommandBuffer {
    fileprivate let native: MTLIndirectCommandBuffer
    public let descriptor: IndirectCommandBufferDescriptor

    fileprivate init(
        native: MTLIndirectCommandBuffer,
        descriptor: IndirectCommandBufferDescriptor
    ) {
        self.native = native
        self.descriptor = descriptor
    }

    public var maxCommandCount: UInt32 {
        descriptor.maxCommandCount
    }

    fileprivate func rangeIsValid(start: UInt32, count: UInt32) -> Bool {
        UInt64(start) + UInt64(count) <= UInt64(maxCommandCount)
    }

    public func reset(rangeStart: UInt32, count: UInt32) -> Bool {
        guard rangeIsValid(start: rangeStart, count: count),
              UInt64(rangeStart) <= UInt64(Int.max),
              UInt64(count) <= UInt64(Int.max) else {
            return false
        }
        native.reset(
            with: NSRange(
                location: Int(rangeStart),
                length: Int(count)
            )
        )
        return true
    }

    public func renderCommand(_ index: UInt32) -> IndirectRenderCommand? {
        guard index < maxCommandCount,
              UInt64(index) <= UInt64(Int.max) else {
            return nil
        }
        return IndirectRenderCommand(
            native: native.indirectRenderCommandAt(Int(index))
        )
    }

    public func computeCommand(_ index: UInt32) -> IndirectComputeCommand? {
        guard index < maxCommandCount,
              UInt64(index) <= UInt64(Int.max) else {
            return nil
        }
        return IndirectComputeCommand(
            native: native.indirectComputeCommandAt(Int(index))
        )
    }

    public var label: String {
        get { native.label ?? "" }
        set { native.label = newValue.isEmpty ? nil : newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class ShaderFunction {
    fileprivate let native: MTLFunction
    private let signatureStorage: String
    private var labelStorage = ""

    fileprivate init(native: MTLFunction, signature: String? = nil) {
        self.native = native
        self.signatureStorage = signature
            ?? "\(native.name):\(ObjectIdentifier(native as AnyObject).hashValue)"
    }

    public var name: String {
        native.name
    }

    public var signature: String {
        signatureStorage
    }

    public var functionType: ShaderFunctionType {
        ShaderFunctionType(metalFunctionType: native.functionType)
    }

    public var label: String {
        get { labelStorage }
        set { labelStorage = newValue }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class ShaderLibrary {
    fileprivate let native: MTLLibrary
    private var errorDescriptionStorage = ""
    private var labelStorage = ""

    fileprivate init(native: MTLLibrary) {
        self.native = native
    }

    public var label: String {
        get { labelStorage }
        set { labelStorage = newValue }
    }

    public var functionCount: UInt32 {
        UInt32(native.functionNames.count)
    }

    public func functionName(_ index: UInt32) -> String {
        guard index < UInt32(native.functionNames.count) else {
            return ""
        }
        return native.functionNames[Int(index)]
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func function(_ name: String) -> ShaderFunction? {
        guard let function = native.makeFunction(name: name) else {
            errorDescriptionStorage =
                "Metal function not found: \(name)"
            return nil
        }
        return ShaderFunction(native: function)
    }

    public func specializedFunction(
        _ name: String,
        constants: FunctionConstants
    ) -> ShaderFunction? {
        do {
            let function = try native.makeFunction(
                name: name,
                constantValues: constants.native
            )
            return ShaderFunction(
                native: function,
                signature: "\(name)|\(constants.signature)|"
                    + "\(ObjectIdentifier(function as AnyObject).hashValue)"
            )
        } catch {
            errorDescriptionStorage = errorDescription(for: error)
            return nil
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }

    fileprivate func setError(_ error: Error) {
        errorDescriptionStorage = Self.errorDescription(for: error)
    }

    private static func errorDescription(for error: Error) -> String {
        error.localizedDescription
    }
}

public final class BindingLayout {
    private var entries: [BindingInfo] = []
    private var validationErrorStorage = ""

    public init() {}

    public var count: UInt32 {
        UInt32(entries.count)
    }

    public var signature: String {
        entries.sorted {
            if $0.name == $1.name {
                return $0.index < $1.index
            }
            return $0.name < $1.name
        }.map {
            [
                $0.name,
                String($0.kind.rawValue),
                String($0.stages),
                String($0.index),
                String($0.arrayLength),
                String($0.dataSize),
                String($0.alignment),
                String($0.updateFrequency.rawValue)
            ].joined(separator: ":")
        }.joined(separator: "|")
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func addBinding(_ binding: BindingInfo) -> Bool {
        guard !binding.name.isEmpty,
              binding.arrayLength > 0,
              binding.stages != 0,
              binding.kind != .unknown,
              binding.alignment == 0
                || (binding.alignment & (binding.alignment - 1)) == 0,
              binding.alignment == 0
                || binding.dataSize == 0
                || binding.dataSize % binding.alignment == 0 else {
            validationErrorStorage =
                "Binding names, kinds, stages, arrays, and aligned data "
                + "sizes are required."
            return false
        }
        guard !entries.contains(where: {
            $0.name == binding.name ||
                ($0.kind == binding.kind &&
                    $0.index == binding.index &&
                    $0.stages & binding.stages != 0)
        }) else {
            validationErrorStorage =
                "Binding name, index, and stage visibility must be unique."
            return false
        }
        entries.append(binding)
        validationErrorStorage = ""
        return true
    }

    public func binding(_ index: UInt32) -> BindingInfo? {
        guard index < UInt32(entries.count) else {
            return nil
        }
        return entries[Int(index)]
    }

    fileprivate var allEntries: [BindingInfo] {
        entries
    }
}

public final class PipelineReflection {
    private let resources: [PipelineResourceInfo]
    private var validationErrorStorage = ""

    init(resources: [PipelineResourceInfo]) {
        self.resources = resources
    }

    fileprivate convenience init(
        renderReflection: MTLRenderPipelineReflection?
    ) {
        var resources: [PipelineResourceInfo] = []
        if let renderReflection {
            for argument in renderReflection.vertexArguments {
                if let info = resourceInfo(
                    from: argument,
                    stages: UInt32(ShaderStage.vertex.rawValue)
                ) {
                    resources.append(info)
                }
            }
            for argument in renderReflection.fragmentArguments {
                if let info = resourceInfo(
                    from: argument,
                    stages: UInt32(ShaderStage.fragment.rawValue)
                ) {
                    resources.append(info)
                }
            }
        }
        self.init(resources: resources)
    }

    fileprivate convenience init(
        computeReflection: MTLComputePipelineReflection?
    ) {
        var resources: [PipelineResourceInfo] = []
        if let computeReflection {
            for argument in computeReflection.arguments {
                if let info = resourceInfo(
                    from: argument,
                    stages: UInt32(ShaderStage.compute.rawValue)
                ) {
                    resources.append(info)
                }
            }
        }
        self.init(resources: resources)
    }

    public var resourceCount: UInt32 {
        UInt32(resources.count)
    }

    public var validationError: String {
        validationErrorStorage
    }

    public func resource(_ index: UInt32) -> PipelineResourceInfo? {
        guard index < UInt32(resources.count) else {
            return nil
        }
        return resources[Int(index)]
    }

    public func validate(_ layout: BindingLayout) -> Bool {
        validationErrorStorage = ""
        var matchedNames = Set<String>()
        for resource in resources {
            guard let binding = layout.allEntries.first(where: {
                $0.name == resource.name
            }) else {
                validationErrorStorage =
                    "Reflected resource is missing from the binding layout: "
                    + resource.name
                return false
            }
            matchedNames.insert(binding.name)
            guard binding.kind == resource.kind,
                  binding.index == resource.index,
                  binding.arrayLength >= resource.arrayLength,
                  binding.stages & resource.stages == resource.stages else {
                validationErrorStorage =
                    "Binding layout mismatch for resource: " + resource.name
                return false
            }
            if binding.dataSize > 0,
               resource.dataSize > 0,
               binding.dataSize < resource.dataSize {
                validationErrorStorage =
                    "Binding layout data size is smaller than reflected "
                    + "resource: " + resource.name
                return false
            }
            if binding.alignment > 0,
               resource.alignment > 0,
               binding.alignment < resource.alignment {
                validationErrorStorage =
                    "Binding layout alignment is smaller than reflected "
                    + "resource: " + resource.name
                return false
            }
        }
        if let extra = layout.allEntries.first(where: {
            !matchedNames.contains($0.name)
        }) {
            validationErrorStorage =
                "Binding layout contains an extra resource: " + extra.name
            return false
        }
        return true
    }
}

fileprivate func bindingKind(for argument: MTLArgument) -> BindingKind {
    switch argument.type {
    case .buffer:
        return argument.isArgumentBuffer ? .argumentBuffer : .buffer
    case .texture:
        return .texture
    case .sampler:
        return .sampler
    case .threadgroupMemory:
        return .threadgroupMemory
    case .imageblock:
        return .bytes
    @unknown default:
        return .unknown
    }
}

fileprivate func resourceAccess(for argument: MTLArgument) -> ResourceAccess {
    switch argument.access {
    case .readOnly:
        return .read
    case .writeOnly:
        return .write
    case .readWrite:
        return .readWrite
    @unknown default:
        return .unknown
    }
}

fileprivate func resourceInfo(
    from argument: MTLArgument,
    stages: UInt32
) -> PipelineResourceInfo? {
    guard argument.isActive else {
        return nil
    }
    return PipelineResourceInfo(
        name: argument.name,
        kind: bindingKind(for: argument),
        stages: stages,
        index: UInt32(argument.index),
        arrayLength: UInt32(max(1, argument.arrayLength)),
        dataSize: UInt32(max(0, argument.bufferDataSize)),
        alignment: UInt32(max(0, argument.bufferAlignment)),
        access: resourceAccess(for: argument)
    )
}

fileprivate struct ColorAttachmentConfiguration {
    var descriptor: ColorAttachmentDescriptor?
}

fileprivate struct VertexAttributeConfiguration {
    var format: VertexFormat
    var offset: UInt32
    var bufferIndex: UInt32
}

fileprivate struct VertexBufferLayoutConfiguration {
    var stride: UInt32
    var stepFunction: VertexStepFunction
    var stepRate: UInt32
}

fileprivate func makeMetalStencilDescriptor(
    _ descriptor: StencilFaceDescriptor
) -> MTLStencilDescriptor {
    let metal = MTLStencilDescriptor()
    metal.stencilCompareFunction = descriptor.stencilCompareFunction.metalFunction
    metal.stencilFailureOperation = descriptor.stencilFailureOperation.metalOperation
    metal.depthFailureOperation = descriptor.depthFailureOperation.metalOperation
    metal.depthStencilPassOperation =
        descriptor.depthStencilPassOperation.metalOperation
    metal.readMask = descriptor.readMask
    metal.writeMask = descriptor.writeMask
    return metal
}

fileprivate extension DepthStencilDescriptor {
    var metalDescriptor: MTLDepthStencilDescriptor {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = depthCompareFunction.metalFunction
        descriptor.isDepthWriteEnabled = depthWriteEnabled
        descriptor.frontFaceStencil =
            makeMetalStencilDescriptor(frontFaceStencil)
        descriptor.backFaceStencil =
            makeMetalStencilDescriptor(backFaceStencil)
        descriptor.label = label
        return descriptor
    }
}

public final class DepthStencilState {
    fileprivate let native: MTLDepthStencilState
    public let descriptor: DepthStencilDescriptor
    private var labelStorage = ""

    fileprivate init(
        native: MTLDepthStencilState,
        descriptor: DepthStencilDescriptor
    ) {
        self.native = native
        self.descriptor = descriptor
        self.labelStorage = descriptor.label
    }

    public var label: String {
        labelStorage
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class LinkedFunctions {
    fileprivate let native: MTLLinkedFunctions
    private var functionStorage: [MTLFunction] = []
    private var privateFunctionStorage: [MTLFunction] = []

    public init() {
        self.native = MTLLinkedFunctions()
    }

    public var functionCount: UInt32 {
        UInt32(functionStorage.count)
    }

    public var privateFunctionCount: UInt32 {
        UInt32(privateFunctionStorage.count)
    }

    public func setFunctions(_ functions: [ShaderFunction]) {
        functionStorage = functions.map(\.native)
        native.functions = functionStorage
    }

    public func addFunction(_ function: ShaderFunction) {
        functionStorage.append(function.native)
        native.functions = functionStorage
    }

    public func clearFunctions() {
        functionStorage.removeAll(keepingCapacity: true)
        native.functions = []
    }

    public func addPrivateFunction(_ function: ShaderFunction) {
        privateFunctionStorage.append(function.native)
        native.privateFunctions = privateFunctionStorage
    }

    public func clearPrivateFunctions() {
        privateFunctionStorage.removeAll(keepingCapacity: true)
        native.privateFunctions = []
    }

    fileprivate var cacheSignature: String {
        let functions = functionStorage.map(\.name).joined(separator: ",")
        let privateFunctions = privateFunctionStorage
            .map(\.name)
            .joined(separator: ",")
        return "public=\(functions);private=\(privateFunctions)"
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class DynamicLibrary {
    fileprivate let native: MTLDynamicLibrary
    private var labelStorage = ""
    private var errorDescriptionStorage = ""

    fileprivate init(native: MTLDynamicLibrary, label: String = "") {
        self.native = native
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func serialize(to path: String) -> Bool {
        do {
            try native.serialize(to: URL(fileURLWithPath: path))
            errorDescriptionStorage = ""
            return true
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return false
        }
    }

    fileprivate var cacheSignature: String {
        "\(labelStorage):\(ObjectIdentifier(native as AnyObject).hashValue)"
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class BinaryArchive {
    fileprivate let native: MTLBinaryArchive
    public let deviceRegistryID: UInt64
    private var errorDescriptionStorage = ""
    private var labelStorage = ""

    fileprivate init(
        native: MTLBinaryArchive,
        deviceRegistryID: UInt64,
        label: String = ""
    ) {
        self.native = native
        self.deviceRegistryID = deviceRegistryID
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public func addRenderPipelineFunctions(
        _ descriptor: RenderPipelineDescriptor
    ) -> Bool {
        guard !descriptor.usesMeshFunctions else {
            errorDescriptionStorage =
                "Mesh pipelines must use addMeshPipelineFunctions."
            return false
        }
        do {
            try native.addRenderPipelineFunctions(
                descriptor: descriptor.makeMetalDescriptor()
            )
            errorDescriptionStorage = ""
            return true
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return false
        }
    }

    public func addMeshPipelineFunctions(
        _ descriptor: RenderPipelineDescriptor
    ) -> Bool {
        guard descriptor.usesMeshFunctions else {
            errorDescriptionStorage =
                "The render pipeline descriptor does not use mesh shaders."
            return false
        }
        guard #available(macOS 15.0, *) else {
            errorDescriptionStorage =
                "Mesh pipeline binary archives require macOS 15 or newer."
            return false
        }
        guard let metalDescriptor = descriptor.makeMetalMeshDescriptor()
        else {
            errorDescriptionStorage =
                "The mesh pipeline descriptor contains unsupported options."
            return false
        }
        do {
            try native.addMeshRenderPipelineFunctions(
                descriptor: metalDescriptor
            )
            errorDescriptionStorage = ""
            return true
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return false
        }
    }

    public func addComputePipelineFunctions(
        _ descriptor: ComputePipelineDescriptor
    ) -> Bool {
        do {
            try native.addComputePipelineFunctions(
                descriptor: descriptor.makeMetalDescriptor()
            )
            errorDescriptionStorage = ""
            return true
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return false
        }
    }

    public func serialize(to path: String) -> Bool {
        do {
            try native.serialize(to: URL(fileURLWithPath: path))
            errorDescriptionStorage = ""
            return true
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return false
        }
    }

    fileprivate var cacheSignature: String {
        "\(deviceRegistryID):\(ObjectIdentifier(native as AnyObject).hashValue)"
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class RenderPipelineDescriptor {
    private var vertexFunctionStorage: ShaderFunction?
    private var fragmentFunctionStorage: ShaderFunction?
    private var objectFunctionStorage: ShaderFunction?
    private var meshFunctionStorage: ShaderFunction?
    private var bindingLayoutStorage: BindingLayout?
    private var binaryArchiveStorage: [BinaryArchive] = []
    private var vertexPreloadedLibraryStorage: [DynamicLibrary] = []
    private var fragmentPreloadedLibraryStorage: [DynamicLibrary] = []
    private var vertexLinkedFunctionsStorage: LinkedFunctions?
    private var fragmentLinkedFunctionsStorage: LinkedFunctions?
    private var colorAttachmentStorage = Array(
        repeating: ColorAttachmentConfiguration(descriptor: nil),
        count: 8
    )
    private var vertexAttributeStorage: [UInt32: VertexAttributeConfiguration]
        = [:]
    private var vertexLayoutStorage: [UInt32: VertexBufferLayoutConfiguration]
        = [:]
    private var validationErrorStorage = ""

    public var sampleCount: UInt32 = 1
    public var primitiveType: PrimitiveType = .triangle
    public var cullMode: CullMode = .none
    public var frontFacingWinding: Winding = .counterClockwise
    public var depthStencilPixelFormat: PixelFormat = .invalid
    public var supportsIndirectCommandBuffers: Bool = false
    public var maxTotalThreadsPerObjectThreadgroup: UInt32 = 0
    public var maxTotalThreadsPerMeshThreadgroup: UInt32 = 0
    public var payloadMemoryLength: UInt32 = 0
    public var label: String = ""

    public init() {}

    public var validationError: String {
        validationErrorStorage
    }

    public func setVertexFunction(_ function: ShaderFunction) {
        vertexFunctionStorage = function
    }

    public func setFragmentFunction(_ function: ShaderFunction) {
        fragmentFunctionStorage = function
    }

    public func setObjectFunction(_ function: ShaderFunction) {
        objectFunctionStorage = function
    }

    public func setMeshFunction(_ function: ShaderFunction) {
        meshFunctionStorage = function
    }

    public func clearVertexFunction() {
        vertexFunctionStorage = nil
    }

    public func clearFragmentFunction() {
        fragmentFunctionStorage = nil
    }

    public func clearObjectFunction() {
        objectFunctionStorage = nil
    }

    public func clearMeshFunction() {
        meshFunctionStorage = nil
    }

    public func setBindingLayout(_ layout: BindingLayout) {
        bindingLayoutStorage = layout
    }

    public func clearBindingLayout() {
        bindingLayoutStorage = nil
    }

    public func addBinaryArchive(_ archive: BinaryArchive) {
        binaryArchiveStorage.append(archive)
    }

    public func clearBinaryArchives() {
        binaryArchiveStorage.removeAll(keepingCapacity: true)
    }

    public func addVertexPreloadedLibrary(_ library: DynamicLibrary) {
        vertexPreloadedLibraryStorage.append(library)
    }

    public func clearVertexPreloadedLibraries() {
        vertexPreloadedLibraryStorage.removeAll(keepingCapacity: true)
    }

    public func addFragmentPreloadedLibrary(_ library: DynamicLibrary) {
        fragmentPreloadedLibraryStorage.append(library)
    }

    public func clearFragmentPreloadedLibraries() {
        fragmentPreloadedLibraryStorage.removeAll(keepingCapacity: true)
    }

    public func setVertexLinkedFunctions(_ functions: LinkedFunctions) {
        vertexLinkedFunctionsStorage = functions
    }

    public func clearVertexLinkedFunctions() {
        vertexLinkedFunctionsStorage = nil
    }

    public func setFragmentLinkedFunctions(_ functions: LinkedFunctions) {
        fragmentLinkedFunctionsStorage = functions
    }

    public func clearFragmentLinkedFunctions() {
        fragmentLinkedFunctionsStorage = nil
    }

    public func setColorAttachment(
        _ descriptor: ColorAttachmentDescriptor,
        index: UInt32
    ) -> Bool {
        guard index < 8, descriptor.pixelFormat.isColorFormat else {
            validationErrorStorage =
                "Color attachment index or format is invalid."
            return false
        }
        colorAttachmentStorage[Int(index)] =
            ColorAttachmentConfiguration(descriptor: descriptor)
        validationErrorStorage = ""
        return true
    }

    public func clearColorAttachment(index: UInt32) -> Bool {
        guard index < 8 else {
            return false
        }
        colorAttachmentStorage[Int(index)] =
            ColorAttachmentConfiguration(descriptor: nil)
        return true
    }

    public func setVertexAttribute(
        index: UInt32,
        format: VertexFormat,
        offset: UInt32,
        bufferIndex: UInt32
    ) -> Bool {
        guard index < 31, format != .invalid else {
            return false
        }
        vertexAttributeStorage[index] = VertexAttributeConfiguration(
            format: format,
            offset: offset,
            bufferIndex: bufferIndex
        )
        return true
    }

    public func setVertexBufferLayout(
        index: UInt32,
        stride: UInt32,
        stepFunction: VertexStepFunction,
        stepRate: UInt32
    ) -> Bool {
        guard index < 31, stride > 0, stepRate > 0 else {
            return false
        }
        vertexLayoutStorage[index] = VertexBufferLayoutConfiguration(
            stride: stride,
            stepFunction: stepFunction,
            stepRate: stepRate
        )
        return true
    }

    fileprivate var vertexFunction: ShaderFunction? {
        vertexFunctionStorage
    }

    fileprivate var fragmentFunction: ShaderFunction? {
        fragmentFunctionStorage
    }

    fileprivate var objectFunction: ShaderFunction? {
        objectFunctionStorage
    }

    fileprivate var meshFunction: ShaderFunction? {
        meshFunctionStorage
    }

    fileprivate var bindingLayout: BindingLayout? {
        bindingLayoutStorage
    }

    fileprivate var usesMeshFunctions: Bool {
        objectFunctionStorage != nil || meshFunctionStorage != nil
    }

    fileprivate func makeMetalDescriptor(
        additionalBinaryArchives: [BinaryArchive] = []
    ) -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = label.isEmpty ? nil : label
        descriptor.vertexFunction = vertexFunctionStorage?.native
        descriptor.fragmentFunction = fragmentFunctionStorage?.native
        descriptor.inputPrimitiveTopology = primitiveType.metalTopology
        descriptor.rasterSampleCount = Int(sampleCount)
        descriptor.supportIndirectCommandBuffers =
            supportsIndirectCommandBuffers
        descriptor.binaryArchives = (
            binaryArchiveStorage + additionalBinaryArchives
        ).map(\.native)
        descriptor.vertexPreloadedLibraries =
            vertexPreloadedLibraryStorage.map(\.native)
        descriptor.fragmentPreloadedLibraries =
            fragmentPreloadedLibraryStorage.map(\.native)
        descriptor.vertexLinkedFunctions = vertexLinkedFunctionsStorage?.native
        descriptor.fragmentLinkedFunctions =
            fragmentLinkedFunctionsStorage?.native

        if depthStencilPixelFormat != .invalid {
            if depthStencilPixelFormat.isDepthFormat {
                descriptor.depthAttachmentPixelFormat =
                    depthStencilPixelFormat.metalFormat
            }
            if depthStencilPixelFormat.isStencilFormat {
                descriptor.stencilAttachmentPixelFormat =
                    depthStencilPixelFormat.metalFormat
            }
        }

        if !vertexAttributeStorage.isEmpty || !vertexLayoutStorage.isEmpty {
            let vertexDescriptor = MTLVertexDescriptor()
            for (index, attribute) in vertexAttributeStorage {
                let metalAttribute = vertexDescriptor.attributes[Int(index)]
                metalAttribute.format = attribute.format.metalFormat
                metalAttribute.offset = Int(attribute.offset)
                metalAttribute.bufferIndex = Int(attribute.bufferIndex)
            }
            for (index, layout) in vertexLayoutStorage {
                let metalLayout = vertexDescriptor.layouts[Int(index)]
                metalLayout.stride = Int(layout.stride)
                metalLayout.stepFunction = layout.stepFunction.metalFunction
                metalLayout.stepRate = Int(layout.stepRate)
            }
            descriptor.vertexDescriptor = vertexDescriptor
        }

        for index in 0..<colorAttachmentStorage.count {
            guard let color = colorAttachmentStorage[index].descriptor else {
                continue
            }
            let attachment = descriptor.colorAttachments[index]
            attachment.pixelFormat = color.pixelFormat.metalFormat
            attachment.isBlendingEnabled = color.blendingEnabled
            attachment.sourceRGBBlendFactor =
                color.sourceRGBBlendFactor.metalFactor
            attachment.destinationRGBBlendFactor =
                color.destinationRGBBlendFactor.metalFactor
            attachment.rgbBlendOperation = color.rgbBlendOperation.metalOperation
            attachment.sourceAlphaBlendFactor =
                color.sourceAlphaBlendFactor.metalFactor
            attachment.destinationAlphaBlendFactor =
                color.destinationAlphaBlendFactor.metalFactor
            attachment.alphaBlendOperation =
                color.alphaBlendOperation.metalOperation
            attachment.writeMask = MTLColorWriteMask(
                rawValue: UInt(color.writeMask)
            )
        }
        return descriptor
    }

    fileprivate func makeMetalMeshDescriptor(
        additionalBinaryArchives: [BinaryArchive] = []
    ) -> MTLMeshRenderPipelineDescriptor? {
        guard usesMeshFunctions,
              vertexFunctionStorage == nil,
              vertexAttributeStorage.isEmpty,
              vertexLayoutStorage.isEmpty,
              vertexPreloadedLibraryStorage.isEmpty,
              fragmentPreloadedLibraryStorage.isEmpty,
              vertexLinkedFunctionsStorage == nil else {
            return nil
        }

        let descriptor = MTLMeshRenderPipelineDescriptor()
        descriptor.label = label.isEmpty ? nil : label
        descriptor.objectFunction = objectFunctionStorage?.native
        descriptor.meshFunction = meshFunctionStorage?.native
        descriptor.fragmentFunction = fragmentFunctionStorage?.native
        descriptor.maxTotalThreadsPerObjectThreadgroup = Int(
            maxTotalThreadsPerObjectThreadgroup
        )
        descriptor.maxTotalThreadsPerMeshThreadgroup = Int(
            maxTotalThreadsPerMeshThreadgroup
        )
        descriptor.payloadMemoryLength = Int(payloadMemoryLength)
        descriptor.rasterSampleCount = Int(sampleCount)

        if supportsIndirectCommandBuffers {
            guard #available(macOS 14.0, *) else {
                return nil
            }
            descriptor.supportIndirectCommandBuffers = true
        }

        let archives = (binaryArchiveStorage + additionalBinaryArchives)
            .map(\.native)
        if !archives.isEmpty {
            if #available(macOS 15.0, *) {
                descriptor.binaryArchives = archives
            }
        }

        if let linkedFunctions = fragmentLinkedFunctionsStorage {
            guard #available(macOS 14.0, *) else {
                return nil
            }
            descriptor.fragmentLinkedFunctions = linkedFunctions.native
        }

        if depthStencilPixelFormat != .invalid {
            if depthStencilPixelFormat.isDepthFormat {
                descriptor.depthAttachmentPixelFormat =
                    depthStencilPixelFormat.metalFormat
            }
            if depthStencilPixelFormat.isStencilFormat {
                descriptor.stencilAttachmentPixelFormat =
                    depthStencilPixelFormat.metalFormat
            }
        }

        for index in 0..<colorAttachmentStorage.count {
            guard let color = colorAttachmentStorage[index].descriptor else {
                continue
            }
            let attachment = descriptor.colorAttachments[index]
            attachment.pixelFormat = color.pixelFormat.metalFormat
            attachment.isBlendingEnabled = color.blendingEnabled
            attachment.sourceRGBBlendFactor =
                color.sourceRGBBlendFactor.metalFactor
            attachment.destinationRGBBlendFactor =
                color.destinationRGBBlendFactor.metalFactor
            attachment.rgbBlendOperation = color.rgbBlendOperation.metalOperation
            attachment.sourceAlphaBlendFactor =
                color.sourceAlphaBlendFactor.metalFactor
            attachment.destinationAlphaBlendFactor =
                color.destinationAlphaBlendFactor.metalFactor
            attachment.alphaBlendOperation =
                color.alphaBlendOperation.metalOperation
            attachment.writeMask = MTLColorWriteMask(
                rawValue: UInt(color.writeMask)
            )
        }
        return descriptor
    }

    fileprivate var cacheKeyShaderSignature: String {
        [
            vertexFunctionStorage?.signature ?? "",
            fragmentFunctionStorage?.signature ?? "",
            objectFunctionStorage?.signature ?? "",
            meshFunctionStorage?.signature ?? ""
        ].joined(separator: "|")
    }

    fileprivate var cacheKeyDescriptorSignature: String {
        var parts = [
            "sample=\(sampleCount)",
            "primitive=\(primitiveType.rawValue)",
            "cull=\(cullMode.rawValue)",
            "winding=\(frontFacingWinding.rawValue)",
            "depth=\(depthStencilPixelFormat.rawValue)",
            "icb=\(supportsIndirectCommandBuffers ? 1 : 0)",
            "objectThreads=\(maxTotalThreadsPerObjectThreadgroup)",
            "meshThreads=\(maxTotalThreadsPerMeshThreadgroup)",
            "payload=\(payloadMemoryLength)"
        ]
        parts.append(
            "archives="
                + binaryArchiveStorage.map(\.cacheSignature).joined(separator: ",")
        )
        parts.append(
            "vertexLibraries="
                + vertexPreloadedLibraryStorage
                    .map(\.cacheSignature)
                    .joined(separator: ",")
        )
        parts.append(
            "fragmentLibraries="
                + fragmentPreloadedLibraryStorage
                    .map(\.cacheSignature)
                    .joined(separator: ",")
        )
        parts.append(
            "vertexLinked="
                + (vertexLinkedFunctionsStorage?.cacheSignature ?? "")
        )
        parts.append(
            "fragmentLinked="
                + (fragmentLinkedFunctionsStorage?.cacheSignature ?? "")
        )
        for (index, configuration) in colorAttachmentStorage.enumerated() {
            guard let color = configuration.descriptor else {
                continue
            }
            parts.append(
                "color\(index)=\(color.pixelFormat.rawValue):"
                    + "\(color.blendingEnabled ? 1 : 0):"
                    + "\(color.sourceRGBBlendFactor.rawValue):"
                    + "\(color.destinationRGBBlendFactor.rawValue):"
                    + "\(color.rgbBlendOperation.rawValue):"
                    + "\(color.sourceAlphaBlendFactor.rawValue):"
                    + "\(color.destinationAlphaBlendFactor.rawValue):"
                    + "\(color.alphaBlendOperation.rawValue):"
                    + "\(color.writeMask)"
            )
        }
        for index in vertexAttributeStorage.keys.sorted() {
            guard let attribute = vertexAttributeStorage[index] else {
                continue
            }
            parts.append(
                "attribute\(index)=\(attribute.format.rawValue):"
                    + "\(attribute.offset):\(attribute.bufferIndex)"
            )
        }
        for index in vertexLayoutStorage.keys.sorted() {
            guard let layout = vertexLayoutStorage[index] else {
                continue
            }
            parts.append(
                "layout\(index)=\(layout.stride):"
                    + "\(layout.stepFunction.rawValue):\(layout.stepRate)"
            )
        }
        return parts.joined(separator: ";")
    }

    fileprivate var requiresDynamicLibraries: Bool {
        !vertexPreloadedLibraryStorage.isEmpty
            || !fragmentPreloadedLibraryStorage.isEmpty
            || vertexLinkedFunctionsStorage != nil
            || fragmentLinkedFunctionsStorage != nil
    }
}

public final class ComputePipelineDescriptor {
    private var functionStorage: ShaderFunction?
    private var bindingLayoutStorage: BindingLayout?
    private var binaryArchiveStorage: [BinaryArchive] = []
    private var preloadedLibraryStorage: [DynamicLibrary] = []
    private var linkedFunctionsStorage: LinkedFunctions?
    private var validationErrorStorage = ""

    public var threadGroupSizeIsMultipleOfExecutionWidth: Bool = false
    public private(set) var requestedThreadgroupSize: Extent3D?
    public var label: String = ""

    public init() {}

    public var validationError: String {
        validationErrorStorage
    }

    public func setFunction(_ function: ShaderFunction) {
        functionStorage = function
    }

    public func clearFunction() {
        functionStorage = nil
    }

    public func setRequestedThreadgroupSize(_ size: Extent3D) -> Bool {
        guard size.width > 0, size.height > 0, size.depth > 0 else {
            validationErrorStorage =
                "The requested threadgroup dimensions must be non-zero."
            return false
        }
        requestedThreadgroupSize = size
        validationErrorStorage = ""
        return true
    }

    public func clearRequestedThreadgroupSize() {
        requestedThreadgroupSize = nil
    }

    public func setBindingLayout(_ layout: BindingLayout) {
        bindingLayoutStorage = layout
    }

    public func clearBindingLayout() {
        bindingLayoutStorage = nil
    }

    public func addBinaryArchive(_ archive: BinaryArchive) {
        binaryArchiveStorage.append(archive)
    }

    public func clearBinaryArchives() {
        binaryArchiveStorage.removeAll(keepingCapacity: true)
    }

    public func addPreloadedLibrary(_ library: DynamicLibrary) {
        preloadedLibraryStorage.append(library)
    }

    public func clearPreloadedLibraries() {
        preloadedLibraryStorage.removeAll(keepingCapacity: true)
    }

    public func setLinkedFunctions(_ functions: LinkedFunctions) {
        linkedFunctionsStorage = functions
    }

    public func clearLinkedFunctions() {
        linkedFunctionsStorage = nil
    }

    fileprivate var function: ShaderFunction? {
        functionStorage
    }

    fileprivate var bindingLayout: BindingLayout? {
        bindingLayoutStorage
    }

    fileprivate func makeMetalDescriptor(
        additionalBinaryArchives: [BinaryArchive] = []
    ) -> MTLComputePipelineDescriptor {
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = functionStorage?.native
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth =
            threadGroupSizeIsMultipleOfExecutionWidth
        descriptor.binaryArchives = (
            binaryArchiveStorage + additionalBinaryArchives
        ).map(\.native)
        descriptor.preloadedLibraries = preloadedLibraryStorage.map(\.native)
        descriptor.linkedFunctions = linkedFunctionsStorage?.native
        return descriptor
    }

    fileprivate var cacheKeyShaderSignature: String {
        functionStorage?.signature ?? ""
    }

    fileprivate var cacheKeyDescriptorSignature: String {
        "multiple=\(threadGroupSizeIsMultipleOfExecutionWidth ? 1 : 0)"
            + "|threads="
            + (requestedThreadgroupSize.map {
                "\($0.width)x\($0.height)x\($0.depth)"
            } ?? "")
            + "|archives="
            + binaryArchiveStorage.map(\.cacheSignature).joined(separator: ",")
            + "|libraries="
            + preloadedLibraryStorage
                .map(\.cacheSignature)
                .joined(separator: ",")
            + "|linked="
            + (linkedFunctionsStorage?.cacheSignature ?? "")
    }

    fileprivate var requiresDynamicLibraries: Bool {
        !preloadedLibraryStorage.isEmpty || linkedFunctionsStorage != nil
    }
}

public final class RenderPipeline {
    fileprivate let native: MTLRenderPipelineState
    public let info: RenderPipelineInfo
    public let reflection: PipelineReflection
    fileprivate let cullMode: CullMode
    fileprivate let frontFacingWinding: Winding
    private var labelStorage = ""

    fileprivate init(
        native: MTLRenderPipelineState,
        info: RenderPipelineInfo,
        reflection: PipelineReflection,
        label: String,
        cullMode: CullMode,
        frontFacingWinding: Winding
    ) {
        self.native = native
        self.info = info
        self.reflection = reflection
        self.cullMode = cullMode
        self.frontFacingWinding = frontFacingWinding
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class ComputePipeline {
    fileprivate let native: MTLComputePipelineState
    public let reflection: PipelineReflection
    private let supportsRayTracingStorage: Bool
    private var labelStorage = ""

    fileprivate init(
        native: MTLComputePipelineState,
        reflection: PipelineReflection,
        label: String,
        supportsRayTracing: Bool = false
    ) {
        self.native = native
        self.reflection = reflection
        self.supportsRayTracingStorage = supportsRayTracing
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var threadExecutionWidth: UInt32 {
        UInt32(native.threadExecutionWidth)
    }

    public var maxThreadsPerThreadgroup: UInt32 {
        UInt32(native.maxTotalThreadsPerThreadgroup)
    }

    public var staticThreadgroupMemoryLength: UInt32 {
        UInt32(native.staticThreadgroupMemoryLength)
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public var supportsRayTracing: Bool {
        supportsRayTracingStorage
    }

    public func makeIntersectionFunctionTable(
        functionCount: UInt32
    ) -> IntersectionFunctionTable? {
        guard supportsRayTracing,
              functionCount > 0,
              UInt64(functionCount) <= UInt64(Int.max) else {
            return nil
        }
        let descriptor = MTLIntersectionFunctionTableDescriptor()
        descriptor.functionCount = Int(functionCount)
        guard let table = native.makeIntersectionFunctionTable(
            descriptor: descriptor
        ) else {
            return nil
        }
        return IntersectionFunctionTable(
            native: table,
            pipeline: native,
            functionCount: functionCount
        )
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class IntersectionFunctionTable {
    fileprivate let native: MTLIntersectionFunctionTable
    private let pipeline: MTLComputePipelineState
    public let functionCount: UInt32

    fileprivate init(
        native: MTLIntersectionFunctionTable,
        pipeline: MTLComputePipelineState,
        functionCount: UInt32
    ) {
        self.native = native
        self.pipeline = pipeline
        self.functionCount = functionCount
    }

    public func setFunction(
        _ function: ShaderFunction,
        index: UInt32
    ) -> Bool {
        guard index < functionCount,
              UInt64(index) <= UInt64(Int.max),
              let handle = pipeline.functionHandle(function: function.native)
        else {
            return false
        }
        native.setFunction(handle, index: Int(index))
        return true
    }

    public func setFunctions(
        _ functions: [ShaderFunction],
        rangeStart: UInt32
    ) -> Bool {
        guard !functions.isEmpty,
              rangeStart <= functionCount,
              UInt64(functions.count) <= UInt64(functionCount - rangeStart),
              UInt64(rangeStart) <= UInt64(Int.max) else {
            return false
        }
        let handles = functions.compactMap {
            pipeline.functionHandle(function: $0.native)
        }
        guard handles.count == functions.count else {
            return false
        }
        native.setFunctions(
            handles,
            range: NSRange(
                location: Int(rangeStart),
                length: functions.count
            )
        )
        return true
    }

    public func setBuffer(
        _ buffer: Buffer,
        offset: UInt64,
        index: UInt32
    ) -> Bool {
        guard rangeFits(length: buffer.length, offset: offset, count: 0),
              UInt64(offset) <= UInt64(Int.max),
              UInt64(index) <= UInt64(Int.max) else {
            return false
        }
        native.setBuffer(
            buffer.native,
            offset: Int(offset),
            index: Int(index)
        )
        return true
    }

    public func setBuffers(
        _ buffers: [Buffer],
        offsets: [UInt64],
        rangeStart: UInt32
    ) -> Bool {
        guard !buffers.isEmpty,
              buffers.count == offsets.count,
              UInt64(rangeStart) <= UInt64(Int.max),
              UInt64(buffers.count) <= UInt64(Int.max) else {
            return false
        }
        guard zip(buffers, offsets).allSatisfy({
            rangeFits(length: $0.0.length, offset: $0.1, count: 0)
                && $0.1 <= UInt64(Int.max)
        }) else {
            return false
        }
        native.setBuffers(
            buffers.map(\.native),
            offsets: offsets.map { Int($0) },
            range: NSRange(
                location: Int(rangeStart),
                length: buffers.count
            )
        )
        return true
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class PipelineCache {
    private let deviceRegistryID: UInt64
    private let sdkSignature: String
    private let lock = NSLock()
    private var renderEntries: [PipelineCacheKey: RenderPipeline] = [:]
    private var computeEntries: [PipelineCacheKey: ComputePipeline] = [:]
    private var persistentArchiveStorage: BinaryArchive?
    private var hitsStorage: UInt64 = 0
    private var missesStorage: UInt64 = 0

    public init(device: Device) {
        self.deviceRegistryID = device.info.registryID
        self.sdkSignature = PipelineCacheKey.currentSDKSignature
    }

    public var hits: UInt64 {
        lock.lock()
        defer { lock.unlock() }
        return hitsStorage
    }

    public var misses: UInt64 {
        lock.lock()
        defer { lock.unlock() }
        return missesStorage
    }

    public var entryCount: UInt32 {
        lock.lock()
        defer { lock.unlock() }
        return UInt32(renderEntries.count + computeEntries.count)
    }

    public var persistentArchive: BinaryArchive? {
        lock.lock()
        defer { lock.unlock() }
        return persistentArchiveStorage
    }

    public func attachPersistentArchive(_ archive: BinaryArchive) -> Bool {
        guard archive.deviceRegistryID == deviceRegistryID else {
            return false
        }
        lock.lock()
        defer { lock.unlock() }
        persistentArchiveStorage = archive
        invalidateAllLocked()
        return true
    }

    public func clearPersistentArchive() {
        lock.lock()
        defer { lock.unlock() }
        persistentArchiveStorage = nil
        invalidateAllLocked()
    }

    public func serializePersistentArchive(to path: String) -> Bool {
        lock.lock()
        let archive = persistentArchiveStorage
        lock.unlock()
        return archive?.serialize(to: path) ?? false
    }

    public func invalidate(_ key: PipelineCacheKey) {
        lock.lock()
        defer { lock.unlock() }
        renderEntries.removeValue(forKey: key)
        computeEntries.removeValue(forKey: key)
    }

    public func invalidateAll() {
        lock.lock()
        defer { lock.unlock() }
        invalidateAllLocked()
    }

    private func invalidateAllLocked() {
        renderEntries.removeAll(keepingCapacity: true)
        computeEntries.removeAll(keepingCapacity: true)
    }

    public func resetStatistics() {
        lock.lock()
        defer { lock.unlock() }
        hitsStorage = 0
        missesStorage = 0
    }

    fileprivate func renderPipeline(for key: PipelineCacheKey)
        -> RenderPipeline? {
        lock.lock()
        defer { lock.unlock() }
        guard key.deviceRegistryID == deviceRegistryID,
              key.sdkSignature == sdkSignature,
              key.kind == .render else {
            missesStorage += 1
            return nil
        }
        if let pipeline = renderEntries[key] {
            hitsStorage += 1
            return pipeline
        }
        missesStorage += 1
        return nil
    }

    fileprivate func computePipeline(for key: PipelineCacheKey)
        -> ComputePipeline? {
        lock.lock()
        defer { lock.unlock() }
        guard key.deviceRegistryID == deviceRegistryID,
              key.sdkSignature == sdkSignature,
              key.kind == .compute else {
            missesStorage += 1
            return nil
        }
        if let pipeline = computeEntries[key] {
            hitsStorage += 1
            return pipeline
        }
        missesStorage += 1
        return nil
    }

    fileprivate func store(
        _ pipeline: RenderPipeline,
        for key: PipelineCacheKey
    ) {
        lock.lock()
        defer { lock.unlock() }
        guard key.deviceRegistryID == deviceRegistryID,
              key.sdkSignature == sdkSignature,
              key.kind == .render else {
            return
        }
        renderEntries[key] = pipeline
    }

    fileprivate func store(
        _ pipeline: ComputePipeline,
        for key: PipelineCacheKey
    ) {
        lock.lock()
        defer { lock.unlock() }
        guard key.deviceRegistryID == deviceRegistryID,
              key.sdkSignature == sdkSignature,
              key.kind == .compute else {
            return
        }
        computeEntries[key] = pipeline
    }

    fileprivate var persistentBinaryArchives: [BinaryArchive] {
        lock.lock()
        defer { lock.unlock() }
        guard let archive = persistentArchiveStorage else {
            return []
        }
        return [archive]
    }

    fileprivate var persistentArchiveSignature: String {
        lock.lock()
        defer { lock.unlock() }
        return persistentArchiveStorage.map {
            "archive:\($0.deviceRegistryID)"
        } ?? ""
    }
}

public final class TilePipelineDescriptor {
    private var tileFunctionStorage: ShaderFunction?
    private var colorAttachmentStorage = Array(
        repeating: PixelFormat.invalid,
        count: 8
    )
    private var validationErrorStorage = ""

    public var sampleCount: UInt32 = 1
    public var threadgroupSizeMatchesTileSize: Bool = false
    public var maxTotalThreadsPerThreadgroup: UInt32 = 0
    public var label: String = ""

    public init() {}

    public var validationError: String {
        validationErrorStorage
    }

    public func validate() -> Bool {
        validationErrorStorage = ""
        guard sampleCount > 0 else {
            validationErrorStorage =
                "The tile pipeline sample count must be non-zero."
            return false
        }
        return true
    }

    public func setTileFunction(_ function: ShaderFunction) {
        tileFunctionStorage = function
    }

    public func clearTileFunction() {
        tileFunctionStorage = nil
    }

    public func setColorAttachment(
        _ pixelFormat: PixelFormat,
        index: UInt32
    ) -> Bool {
        guard index < 8, pixelFormat.isColorFormat else {
            validationErrorStorage =
                "Tile color attachment index or format is invalid."
            return false
        }
        colorAttachmentStorage[Int(index)] = pixelFormat
        validationErrorStorage = ""
        return true
    }

    public func clearColorAttachment(index: UInt32) -> Bool {
        guard index < 8 else {
            return false
        }
        colorAttachmentStorage[Int(index)] = .invalid
        return true
    }

    fileprivate var tileFunction: ShaderFunction? {
        tileFunctionStorage
    }

    fileprivate func makeMetalDescriptor()
        -> MTLTileRenderPipelineDescriptor {
        let descriptor = MTLTileRenderPipelineDescriptor()
        descriptor.tileFunction = tileFunctionStorage?.native
        descriptor.rasterSampleCount = Int(sampleCount)
        descriptor.threadgroupSizeMatchesTileSize =
            threadgroupSizeMatchesTileSize
        descriptor.maxTotalThreadsPerThreadgroup = Int(
            maxTotalThreadsPerThreadgroup
        )
        for index in 0..<colorAttachmentStorage.count {
            let pixelFormat = colorAttachmentStorage[index]
            guard pixelFormat != .invalid else {
                continue
            }
            descriptor.colorAttachments[index].pixelFormat =
                pixelFormat.metalFormat
        }
        return descriptor
    }
}

public final class TilePipeline {
    fileprivate let native: MTLRenderPipelineState
    private var labelStorage = ""

    fileprivate init(native: MTLRenderPipelineState, label: String) {
        self.native = native
        self.labelStorage = label
        if !label.isEmpty {
            native.label = label
        }
    }

    public var threadExecutionWidth: UInt32 {
        UInt32(native.threadExecutionWidth)
    }

    public var maxThreadsPerThreadgroup: UInt32 {
        UInt32(native.maxTotalThreadsPerThreadgroup)
    }

    public var imageblockMemoryLength: UInt32 {
        UInt32(native.imageblockMemoryLength)
    }

    public var label: String {
        get { labelStorage }
        set {
            labelStorage = newValue
            native.label = newValue.isEmpty ? nil : newValue
        }
    }

    public func nativeHandle() -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(native as AnyObject).toOpaque()
    }
}

public final class Device {
    private let native: MTLDevice
    private var errorDescriptionStorage = ""
    private var capabilityDiagnosticStorage =
        MetalCapabilityDiagnostic.none

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

    public var errorDescription: String {
        errorDescriptionStorage
    }

    public var lastCapabilityDiagnostic: MetalCapabilityDiagnostic {
        capabilityDiagnosticStorage
    }

    fileprivate var metalDevice: MTLDevice {
        native
    }

    private func setCapabilityDiagnostic(
        feature: DeviceFeature,
        kind: MetalCapabilityErrorKind,
        fallbackAvailable: Bool,
        message: String
    ) {
        errorDescriptionStorage = message
        capabilityDiagnosticStorage = MetalCapabilityDiagnostic(
            kind: kind,
            feature: feature,
            fallbackAvailable: fallbackAvailable,
            message: message
        )
    }

    private func clearCapabilityDiagnostic() {
        capabilityDiagnosticStorage = .none
    }

    public func createShaderLibraryFromFile(
        path: String,
        label: String
    ) -> ShaderLibrary? {
        do {
            let library = try native.makeLibrary(
                URL: URL(fileURLWithPath: path)
            )
            let wrapper = ShaderLibrary(native: library)
            wrapper.label = label
            return wrapper
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createShaderLibraryFromSource(
        source: String,
        label: String
    ) -> ShaderLibrary? {
        do {
            let library = try native.makeLibrary(
                source: source,
                options: nil
            )
            let wrapper = ShaderLibrary(native: library)
            wrapper.label = label
            return wrapper
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createPipelineCache() -> PipelineCache {
        PipelineCache(device: self)
    }

    public func createDepthStencilState(
        _ descriptor: DepthStencilDescriptor
    ) -> DepthStencilState? {
        let state = native.makeDepthStencilState(
            descriptor: descriptor.metalDescriptor
        )
        guard let state else {
            errorDescriptionStorage =
                "Metal could not create the depth/stencil state."
            return nil
        }
        errorDescriptionStorage = ""
        return DepthStencilState(native: state, descriptor: descriptor)
    }

    public func createBinaryArchive(
        label: String
    ) -> BinaryArchive? {
        createBinaryArchive(url: nil, label: label)
    }

    public func createBinaryArchiveFromFile(
        path: String,
        label: String
    ) -> BinaryArchive? {
        createBinaryArchive(
            url: URL(fileURLWithPath: path),
            label: label
        )
    }

    private func createBinaryArchive(
        url: URL?,
        label: String
    ) -> BinaryArchive? {
        let descriptor = MTLBinaryArchiveDescriptor()
        descriptor.url = url
        do {
            let archive = try native.makeBinaryArchive(
                descriptor: descriptor
            )
            let wrapper = BinaryArchive(
                native: archive,
                deviceRegistryID: native.registryID,
                label: label
            )
            errorDescriptionStorage = ""
            return wrapper
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createDynamicLibrary(
        from library: ShaderLibrary,
        label: String
    ) -> DynamicLibrary? {
        guard capabilities.dynamicLibraries else {
            errorDescriptionStorage =
                "Dynamic libraries are not supported by this device."
            return nil
        }
        do {
            let library = try native.makeDynamicLibrary(
                library: library.native
            )
            let wrapper = DynamicLibrary(native: library, label: label)
            errorDescriptionStorage = ""
            return wrapper
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createDynamicLibraryFromFile(
        path: String,
        label: String
    ) -> DynamicLibrary? {
        guard capabilities.dynamicLibraries else {
            errorDescriptionStorage =
                "Dynamic libraries are not supported by this device."
            return nil
        }
        do {
            let library = try native.makeDynamicLibrary(
                url: URL(fileURLWithPath: path)
            )
            let wrapper = DynamicLibrary(native: library, label: label)
            errorDescriptionStorage = ""
            return wrapper
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createArgumentBuffer(
        function: ShaderFunction,
        bufferIndex: UInt32,
        storageMode: StorageMode,
        label: String
    ) -> ArgumentBuffer? {
        guard capabilities.argumentBufferCapabilities.supported else {
            errorDescriptionStorage =
                "Argument buffers are not supported by this device."
            return nil
        }
        guard storageMode == .shared || storageMode == .managed else {
            errorDescriptionStorage =
                "CPU-encoded argument buffers require shared or managed "
                + "storage."
            return nil
        }
        guard UInt64(bufferIndex) <= UInt64(Int.max) else {
            errorDescriptionStorage = "The argument-buffer index is invalid."
            return nil
        }

        let encoder = function.native.makeArgumentEncoder(
            bufferIndex: Int(bufferIndex)
        )
        guard encoder.encodedLength > 0,
              UInt64(encoder.encodedLength) <= UInt64(Int.max) else {
            errorDescriptionStorage =
                "The shader function does not expose an argument buffer at "
                + "the requested index."
            return nil
        }
        let descriptor = BufferDescriptor(
            length: UInt64(encoder.encodedLength),
            usage: UInt32(BufferUsage.storage.rawValue),
            storageMode: storageMode,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
        guard let backing = createBuffer(descriptor) else {
            errorDescriptionStorage =
                "Metal could not allocate the argument buffer backing store."
            return nil
        }
        errorDescriptionStorage = ""
        return ArgumentBuffer(
            backing: backing,
            encoder: encoder,
            supportsNestedBuffers:
                capabilities.argumentBufferCapabilities.supportsNestedBuffers
        )
    }

    public func createRenderPipeline(
        _ descriptor: RenderPipelineDescriptor
    ) -> RenderPipeline? {
        createRenderPipeline(descriptor, cache: nil)
    }

    public func createRenderPipeline(
        _ descriptor: RenderPipelineDescriptor,
        cache: PipelineCache?
    ) -> RenderPipeline? {
        let cacheKey = PipelineCacheKey(
            deviceRegistryID: native.registryID,
            kind: .render,
            shaderSignature: descriptor.cacheKeyShaderSignature,
            layoutSignature: descriptor.bindingLayout?.signature ?? "",
            descriptorSignature: descriptor.cacheKeyDescriptorSignature
                + "|"
                + (cache?.persistentArchiveSignature ?? "")
        )
        if let cache,
           let cached = cache.renderPipeline(for: cacheKey) {
            errorDescriptionStorage = ""
            return cached
        }
        guard !descriptor.requiresDynamicLibraries
                || capabilities.dynamicLibraries else {
            errorDescriptionStorage =
                "Dynamic libraries are not supported by this device."
            return nil
        }
        guard descriptor.sampleCount > 0,
              UInt64(descriptor.sampleCount) <= UInt64(Int.max),
              native.supportsTextureSampleCount(
                  Int(descriptor.sampleCount)
              ) else {
            errorDescriptionStorage =
                "The render pipeline sample count is unsupported."
            return nil
        }
        guard !descriptor.supportsIndirectCommandBuffers
                || capabilities.indirectCommandBuffers else {
            setCapabilityDiagnostic(
                feature: .indirectCommandBuffers,
                kind: .unsupported,
                fallbackAvailable: true,
                message:
                    "Indirect command buffers are not supported by this "
                    + "device."
            )
            return nil
        }

        let usesMeshFunctions = descriptor.usesMeshFunctions
        if usesMeshFunctions {
            guard capabilities.meshShaders,
                  descriptor.meshFunction != nil,
                  descriptor.fragmentFunction != nil,
                  (descriptor.objectFunction == nil
                    || descriptor.objectFunction?.functionType == .object),
                  descriptor.meshFunction?.functionType == .mesh,
                  descriptor.fragmentFunction?.functionType == .fragment else {
                setCapabilityDiagnostic(
                    feature: .meshShaders,
                    kind: .unsupported,
                    fallbackAvailable: true,
                    message:
                        "The device or descriptor does not support mesh "
                        + "shaders."
                )
                return nil
            }
            guard descriptor.maxTotalThreadsPerObjectThreadgroup == 0
                    || UInt64(
                        descriptor.maxTotalThreadsPerObjectThreadgroup
                    ) <= UInt64(capabilities.maxThreadsPerThreadgroup),
                  descriptor.maxTotalThreadsPerMeshThreadgroup == 0
                    || UInt64(
                        descriptor.maxTotalThreadsPerMeshThreadgroup
                    ) <= UInt64(capabilities.maxThreadsPerThreadgroup) else {
                setCapabilityDiagnostic(
                    feature: .meshShaders,
                    kind: .invalid,
                    fallbackAvailable: true,
                    message: "The mesh pipeline thread limit exceeds the "
                        + "device limit."
                )
                return nil
            }
        } else {
            guard descriptor.vertexFunction != nil,
                  descriptor.fragmentFunction != nil,
                  descriptor.vertexFunction?.functionType == .vertex,
                  descriptor.fragmentFunction?.functionType == .fragment else {
                errorDescriptionStorage =
                    "A vertex/fragment render pipeline requires compatible "
                    + "vertex and fragment functions."
                return nil
            }
        }

        if descriptor.depthStencilPixelFormat != .invalid,
           !descriptor.depthStencilPixelFormat.isDepthFormat,
           !descriptor.depthStencilPixelFormat.isStencilFormat {
            errorDescriptionStorage =
                "The depth/stencil pipeline format is unsupported."
            return nil
        }

        if let archive = cache?.persistentArchive {
            if usesMeshFunctions {
                _ = archive.addMeshPipelineFunctions(descriptor)
            } else {
                _ = archive.addRenderPipelineFunctions(descriptor)
            }
        }
        var nativeReflection: MTLRenderPipelineReflection?
        do {
            let state: MTLRenderPipelineState
            if usesMeshFunctions {
                guard let metalDescriptor = descriptor.makeMetalMeshDescriptor(
                    additionalBinaryArchives:
                        cache?.persistentBinaryArchives ?? []
                ) else {
                    setCapabilityDiagnostic(
                        feature: .meshShaders,
                        kind: .invalid,
                        fallbackAvailable: true,
                        message:
                            "The mesh pipeline descriptor contains options "
                            + "that Metal does not support for mesh stages."
                    )
                    return nil
                }
                let result = try native.makeRenderPipelineState(
                    descriptor: metalDescriptor,
                    options: .argumentInfo
                )
                state = result.0
                nativeReflection = result.1
            } else {
                let metalDescriptor = descriptor.makeMetalDescriptor(
                    additionalBinaryArchives:
                        cache?.persistentBinaryArchives ?? []
                )
                state = try native.makeRenderPipelineState(
                    descriptor: metalDescriptor,
                    options: .argumentInfo,
                    reflection: &nativeReflection
                )
            }
            let reflection = PipelineReflection(
                renderReflection: nativeReflection
            )
            if let layout = descriptor.bindingLayout,
               !reflection.validate(layout) {
                errorDescriptionStorage = reflection.validationError
                return nil
            }
            let info = RenderPipelineInfo(
                maxThreadsPerThreadgroup:
                    boundedUInt32(state.maxTotalThreadsPerThreadgroup),
                imageblockMemoryLength:
                    boundedUInt32(state.imageblockMemoryLength),
                supportsIndirectCommandBuffers:
                    state.supportsIndirectCommandBuffers,
                sampleCount: descriptor.sampleCount,
                label: descriptor.label
            )
            errorDescriptionStorage = ""
            let pipeline = RenderPipeline(
                native: state,
                info: info,
                reflection: reflection,
                label: descriptor.label,
                cullMode: descriptor.cullMode,
                frontFacingWinding: descriptor.frontFacingWinding
            )
            cache?.store(pipeline, for: cacheKey)
            return pipeline
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createComputePipeline(
        _ descriptor: ComputePipelineDescriptor
    ) -> ComputePipeline? {
        createComputePipeline(descriptor, cache: nil)
    }

    public func createComputePipeline(
        _ descriptor: ComputePipelineDescriptor,
        cache: PipelineCache?
    ) -> ComputePipeline? {
        let cacheKey = PipelineCacheKey(
            deviceRegistryID: native.registryID,
            kind: .compute,
            shaderSignature: descriptor.cacheKeyShaderSignature,
            layoutSignature: descriptor.bindingLayout?.signature ?? "",
            descriptorSignature: descriptor.cacheKeyDescriptorSignature
                + "|"
                + (cache?.persistentArchiveSignature ?? "")
        )
        if let cache,
           let cached = cache.computePipeline(for: cacheKey) {
            errorDescriptionStorage = ""
            return cached
        }
        guard !descriptor.requiresDynamicLibraries
                || capabilities.dynamicLibraries else {
            errorDescriptionStorage =
                "Dynamic libraries are not supported by this device."
            return nil
        }
        if let requested = descriptor.requestedThreadgroupSize {
            let width = UInt64(requested.width)
            let height = UInt64(requested.height)
            let depth = UInt64(requested.depth)
            guard width > 0,
                  height > 0,
                  depth > 0,
                  width <= UInt64.max / height,
                  width * height <= UInt64.max / depth,
                  width * height * depth
                      <= UInt64(capabilities.maxThreadsPerThreadgroup) else {
                errorDescriptionStorage =
                    "The requested threadgroup size exceeds device limits."
                return nil
            }
        }
        guard let function = descriptor.function,
              function.functionType == .kernel else {
            errorDescriptionStorage =
                "A compute pipeline requires a kernel function."
            return nil
        }

        if let archive = cache?.persistentArchive {
            _ = archive.addComputePipelineFunctions(descriptor)
        }
        let metalDescriptor = descriptor.makeMetalDescriptor(
            additionalBinaryArchives: cache?.persistentBinaryArchives ?? []
        )
        var nativeReflection: MTLComputePipelineReflection?
        do {
            let state = try native.makeComputePipelineState(
                descriptor: metalDescriptor,
                options: .argumentInfo,
                reflection: &nativeReflection
            )
            let reflection = PipelineReflection(
                computeReflection: nativeReflection
            )
            if let layout = descriptor.bindingLayout,
               !reflection.validate(layout) {
                errorDescriptionStorage = reflection.validationError
                return nil
            }
            errorDescriptionStorage = ""
            let pipeline = ComputePipeline(
                native: state,
                reflection: reflection,
                label: descriptor.label,
                supportsRayTracing: capabilities.rayTracing
            )
            cache?.store(pipeline, for: cacheKey)
            return pipeline
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func createTilePipeline(
        _ descriptor: TilePipelineDescriptor
    ) -> TilePipeline? {
        guard capabilities.tileShaderCapabilities.supported else {
            setCapabilityDiagnostic(
                feature: .tileShaders,
                kind: .unsupported,
                fallbackAvailable: true,
                message: "Tile shaders are not supported by this device."
            )
            return nil
        }
        guard descriptor.validate(),
              descriptor.maxTotalThreadsPerThreadgroup == 0
                || UInt64(descriptor.maxTotalThreadsPerThreadgroup)
                    <= UInt64(capabilities.maxThreadsPerThreadgroup) else {
            let message = descriptor.validationError.isEmpty
                ? "The tile pipeline thread limit exceeds the device limit."
                : descriptor.validationError
            setCapabilityDiagnostic(
                feature: .tileShaders,
                kind: .invalid,
                fallbackAvailable: true,
                message: message
            )
            return nil
        }
        guard descriptor.sampleCount > 0,
              native.supportsTextureSampleCount(
                  Int(descriptor.sampleCount)
              ) else {
            setCapabilityDiagnostic(
                feature: .tileShaders,
                kind: .invalid,
                fallbackAvailable: true,
                message: "The tile pipeline sample count is unsupported."
            )
            return nil
        }
        guard let function = descriptor.tileFunction,
              function.functionType == .tile else {
            setCapabilityDiagnostic(
                feature: .tileShaders,
                kind: .invalid,
                fallbackAvailable: true,
                message: "A tile pipeline requires a tile shader function."
            )
            return nil
        }

        var reflection: MTLRenderPipelineReflection?
        do {
            let state = try native.makeRenderPipelineState(
                tileDescriptor: descriptor.makeMetalDescriptor(),
                options: .argumentInfo,
                reflection: &reflection
            )
            errorDescriptionStorage = ""
            return TilePipeline(
                native: state,
                label: descriptor.label
            )
        } catch {
            errorDescriptionStorage = error.localizedDescription
            return nil
        }
    }

    public func accelerationStructureSizes(
        _ descriptor: PrimitiveAccelerationStructureDescriptor
    ) -> AccelerationStructureSizes? {
        guard capabilities.rayTracing else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Ray tracing is not supported by this device."
            )
            return nil
        }
        guard descriptor.motionTriangleGeometryCount == 0
                || capabilities.rayTracingMotion else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Motion acceleration-structure geometry is not "
                    + "supported by this device."
            )
            return nil
        }
        guard let nativeDescriptor = descriptor.makeMetalDescriptor() else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: descriptor.validationError
            )
            return nil
        }
        let sizes = native.accelerationStructureSizes(
            descriptor: nativeDescriptor
        )
        let result = AccelerationStructureSizes(
            accelerationStructureSize: UInt64(sizes.accelerationStructureSize),
            buildScratchBufferSize: UInt64(sizes.buildScratchBufferSize),
            refitScratchBufferSize: UInt64(sizes.refitScratchBufferSize)
        )
        clearCapabilityDiagnostic()
        errorDescriptionStorage = ""
        return result
    }

    public func accelerationStructureSizes(
        _ descriptor: InstanceAccelerationStructureDescriptor
    ) -> AccelerationStructureSizes? {
        guard capabilities.rayTracing else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Ray tracing is not supported by this device."
            )
            return nil
        }
        guard let nativeDescriptor = descriptor.makeMetalDescriptor() else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: descriptor.validationError
            )
            return nil
        }
        let sizes = native.accelerationStructureSizes(
            descriptor: nativeDescriptor
        )
        let result = AccelerationStructureSizes(
            accelerationStructureSize: UInt64(sizes.accelerationStructureSize),
            buildScratchBufferSize: UInt64(sizes.buildScratchBufferSize),
            refitScratchBufferSize: UInt64(sizes.refitScratchBufferSize)
        )
        clearCapabilityDiagnostic()
        errorDescriptionStorage = ""
        return result
    }

    public func createAccelerationStructure(
        _ descriptor: PrimitiveAccelerationStructureDescriptor
    ) -> AccelerationStructure? {
        guard let nativeDescriptor = validatedPrimitiveDescriptor(
            descriptor
        ) else {
            return nil
        }
        let sizes = native.accelerationStructureSizes(
            descriptor: nativeDescriptor
        )
        guard sizes.accelerationStructureSize > 0,
              sizes.accelerationStructureSize <= UInt64(Int.max),
              let accelerationStructure = native.makeAccelerationStructure(
                  size: Int(sizes.accelerationStructureSize)
              ) else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: "Metal could not allocate the acceleration structure."
            )
            return nil
        }
        clearCapabilityDiagnostic()
        errorDescriptionStorage = ""
        return AccelerationStructure(
            native: accelerationStructure,
            sizes: AccelerationStructureSizes(
                accelerationStructureSize:
                    UInt64(sizes.accelerationStructureSize),
                buildScratchBufferSize: UInt64(
                    sizes.buildScratchBufferSize
                ),
                refitScratchBufferSize: UInt64(
                    sizes.refitScratchBufferSize
                )
            ),
            label: descriptor.label
        )
    }

    public func createAccelerationStructure(
        _ descriptor: InstanceAccelerationStructureDescriptor
    ) -> AccelerationStructure? {
        guard let nativeDescriptor = validatedInstanceDescriptor(
            descriptor
        ) else {
            return nil
        }
        let sizes = native.accelerationStructureSizes(
            descriptor: nativeDescriptor
        )
        guard sizes.accelerationStructureSize > 0,
              sizes.accelerationStructureSize <= UInt64(Int.max),
              let accelerationStructure = native.makeAccelerationStructure(
                  size: Int(sizes.accelerationStructureSize)
              ) else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: "Metal could not allocate the acceleration structure."
            )
            return nil
        }
        clearCapabilityDiagnostic()
        errorDescriptionStorage = ""
        return AccelerationStructure(
            native: accelerationStructure,
            sizes: AccelerationStructureSizes(
                accelerationStructureSize:
                    UInt64(sizes.accelerationStructureSize),
                buildScratchBufferSize: UInt64(
                    sizes.buildScratchBufferSize
                ),
                refitScratchBufferSize: UInt64(
                    sizes.refitScratchBufferSize
                )
            ),
            label: descriptor.label
        )
    }

    public func counterSetDescriptions() -> [CounterSetDescription] {
        (native.counterSets ?? []).map { counterSet in
            CounterSetDescription(
                name: counterSet.name,
                counters: counterSet.counters.map {
                    CounterDescription(name: $0.name)
                }
            )
        }
    }

    public func supportsCounterSampling(
        _ point: CounterSamplingPoint
    ) -> Bool {
        native.supportsCounterSampling(point.metalPoint)
    }

    public func createCounterSampleBuffer(
        counterSetName: String,
        sampleCount: UInt32,
        storageMode: StorageMode,
        label: String
    ) -> CounterSampleBuffer? {
        guard capabilities.counterSampling else {
            setCapabilityDiagnostic(
                feature: .counterSampling,
                kind: .unsupported,
                fallbackAvailable: true,
                message: "Counter sampling is not supported by this device."
            )
            return nil
        }
        guard sampleCount > 0,
              UInt64(sampleCount) <= UInt64(Int.max),
              storageMode == .shared || storageMode == .gpuPrivate,
              let counterSet = native.counterSets?.first(where: {
                  $0.name == counterSetName
              }) else {
            setCapabilityDiagnostic(
                feature: .counterSampling,
                kind: .invalid,
                fallbackAvailable: false,
                message: "The counter set or sample-buffer storage mode is "
                    + "invalid."
            )
            return nil
        }
        let descriptor = MTLCounterSampleBufferDescriptor()
        descriptor.counterSet = counterSet
        descriptor.sampleCount = Int(sampleCount)
        descriptor.storageMode = storageMode == .shared ? .shared : .private
        descriptor.label = label
        do {
            let sampleBuffer = try native.makeCounterSampleBuffer(
                descriptor: descriptor
            )
            clearCapabilityDiagnostic()
            errorDescriptionStorage = ""
            return CounterSampleBuffer(
                native: sampleBuffer,
                sampleCount: sampleCount,
                storageMode: storageMode,
                counterSetName: counterSetName,
                label: label
            )
        } catch {
            errorDescriptionStorage = error.localizedDescription
            capabilityDiagnosticStorage = MetalCapabilityDiagnostic(
                kind: .invalid,
                feature: .counterSampling,
                fallbackAvailable: false,
                message: error.localizedDescription
            )
            return nil
        }
    }

    public func createIndirectCommandBuffer(
        _ descriptor: IndirectCommandBufferDescriptor
    ) -> IndirectCommandBuffer? {
        guard capabilities.indirectCommandCapabilities.supported else {
            errorDescriptionStorage =
                "Indirect command buffers are not supported by this device."
            return nil
        }
        guard descriptor.commandTypes != 0,
              descriptor.maxCommandCount > 0,
              UInt64(descriptor.maxCommandCount) <= UInt64(Int.max),
              descriptor.commandTypes & 0xFFFF_FFC0 == 0 else {
            errorDescriptionStorage =
                "The indirect command buffer descriptor is invalid."
            return nil
        }

        let renderCommands = descriptor.commandTypes & 0x0F != 0
        let computeCommands = descriptor.commandTypes & 0x30 != 0
        guard !renderCommands
                || capabilities.indirectCommandCapabilities
                    .supportsRenderCommands,
              !computeCommands
                || capabilities.indirectCommandCapabilities
                    .supportsComputeCommands else {
            errorDescriptionStorage =
                "The requested indirect command type is unsupported."
            return nil
        }
        guard UInt64(descriptor.maxVertexBufferBindCount)
                <= UInt64(Int.max),
              UInt64(descriptor.maxFragmentBufferBindCount)
                <= UInt64(Int.max),
              UInt64(descriptor.maxKernelBufferBindCount)
                <= UInt64(Int.max) else {
            errorDescriptionStorage =
                "The indirect buffer binding limits are invalid."
            return nil
        }

        let metalDescriptor = MTLIndirectCommandBufferDescriptor()
        metalDescriptor.commandTypes = MTLIndirectCommandType(
            rawValue: UInt(descriptor.commandTypes)
        )
        metalDescriptor.inheritBuffers = descriptor.inheritBuffers
        metalDescriptor.inheritPipelineState = descriptor.inheritPipelineState
        metalDescriptor.maxVertexBufferBindCount =
            Int(descriptor.maxVertexBufferBindCount)
        metalDescriptor.maxFragmentBufferBindCount =
            Int(descriptor.maxFragmentBufferBindCount)
        metalDescriptor.maxKernelBufferBindCount =
            Int(descriptor.maxKernelBufferBindCount)

        guard let nativeBuffer = native.makeIndirectCommandBuffer(
            descriptor: metalDescriptor,
            maxCommandCount: Int(descriptor.maxCommandCount)
        ) else {
            errorDescriptionStorage =
                "Metal could not allocate the indirect command buffer."
            return nil
        }
        errorDescriptionStorage = ""
        return IndirectCommandBuffer(
            native: nativeBuffer,
            descriptor: descriptor
        )
    }

    public func createBuffer(_ descriptor: BufferDescriptor) -> Buffer? {
        guard descriptor.length > 0,
              descriptor.length <= UInt64(native.maxBufferLength),
              descriptor.length <= UInt64(Int.max),
              descriptor.storageMode != .memoryless else {
            errorDescriptionStorage =
                "The buffer descriptor has an invalid length or storage mode."
            return nil
        }
        guard let buffer = native.makeBuffer(
            length: Int(descriptor.length),
            options: descriptor.metalResourceOptions
        ) else {
            errorDescriptionStorage =
                "Metal could not allocate the requested buffer."
            return nil
        }
        if !descriptor.label.isEmpty {
            buffer.label = descriptor.label
        }
        errorDescriptionStorage = ""
        return Buffer(native: buffer, usage: descriptor.usage)
    }

    public func createStagingBuffer(
        length: UInt64,
        usage: UInt32,
        label: String
    ) -> Buffer? {
        let descriptor = BufferDescriptor(
            length: length,
            usage: usage,
            storageMode: .shared,
            cpuCacheMode: .defaultCache,
            hazardMode: .defaultMode,
            label: label
        )
        return createBuffer(descriptor)
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
            errorDescriptionStorage =
                "The texture descriptor has an invalid extent or sample count."
            return nil
        }

        if descriptor.textureType.isArray && descriptor.arrayLength == 0 {
            errorDescriptionStorage =
                "Array textures must have a non-zero array length."
            return nil
        }
        if !descriptor.textureType.isArray && descriptor.arrayLength > 1 {
            errorDescriptionStorage =
                "Non-array textures cannot have multiple array slices."
            return nil
        }
        if descriptor.textureType.isMultisample {
            guard descriptor.sampleCount > 1,
                  descriptor.mipLevelCount == 1,
                  native.supportsTextureSampleCount(
                      Int(descriptor.sampleCount)
                  ) else {
                errorDescriptionStorage =
                    "The multisample texture descriptor is unsupported."
                return nil
            }
        } else if descriptor.sampleCount != 1 {
            errorDescriptionStorage =
                "Non-multisample textures must use one sample."
            return nil
        }
        if descriptor.storageMode == .memoryless {
            let renderTargetUsage = UInt32(TextureUsage.renderTarget.rawValue)
            guard capabilities.memorylessAttachments else {
                setCapabilityDiagnostic(
                    feature: .memorylessAttachments,
                    kind: .unsupported,
                    fallbackAvailable: true,
                    message: "Memoryless render targets are not supported "
                        + "by this device."
                )
                return nil
            }
            guard descriptor.usage & renderTargetUsage != 0,
                  descriptor.usage & ~renderTargetUsage == 0 else {
                setCapabilityDiagnostic(
                    feature: .memorylessAttachments,
                    kind: .invalid,
                    fallbackAvailable: true,
                    message: "Memoryless textures may only use render-target "
                        + "usage."
                )
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
            errorDescriptionStorage =
                "Metal could not allocate the requested texture."
            return nil
        }
        if !descriptor.label.isEmpty {
            texture.label = descriptor.label
        }
        errorDescriptionStorage = ""
        clearCapabilityDiagnostic()
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

    public func createResourceRegistry() -> ResourceRegistry {
        ResourceRegistry()
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

    private func validatedPrimitiveDescriptor(
        _ descriptor: PrimitiveAccelerationStructureDescriptor
    ) -> MTLPrimitiveAccelerationStructureDescriptor? {
        guard capabilities.rayTracing else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Ray tracing is not supported by this device."
            )
            return nil
        }
        guard descriptor.motionTriangleGeometryCount == 0
                || capabilities.rayTracingMotion else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Motion acceleration-structure geometry is not "
                    + "supported by this device."
            )
            return nil
        }
        guard let nativeDescriptor = descriptor.makeMetalDescriptor() else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: descriptor.validationError
            )
            return nil
        }
        return nativeDescriptor
    }

    private func validatedInstanceDescriptor(
        _ descriptor: InstanceAccelerationStructureDescriptor
    ) -> MTLInstanceAccelerationStructureDescriptor? {
        guard capabilities.rayTracing else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .unsupported,
                fallbackAvailable: false,
                message: "Ray tracing is not supported by this device."
            )
            return nil
        }
        guard let nativeDescriptor = descriptor.makeMetalDescriptor() else {
            setCapabilityDiagnostic(
                feature: .rayTracing,
                kind: .invalid,
                fallbackAvailable: false,
                message: descriptor.validationError
            )
            return nil
        }
        return nativeDescriptor
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
        let operatingSystemVersion =
            ProcessInfo.processInfo.operatingSystemVersion
        let hasMacFamily = macFamily != .unknown
        let hasAppleFamily = appleFamily != .unknown
        let supportsMeshShaders =
            device.supportsFamily(.mac2) || device.supportsFamily(.apple7)
        let supportsTileShaders = hasAppleFamily || macFamily == .mac2
        let supportsMemorylessAttachments =
            hasAppleFamily || macFamily == .mac2
        let supportsIndirectCommandBuffers = hasMacFamily || hasAppleFamily

        return DeviceCapabilities(
            macFamily: macFamily,
            appleFamily: appleFamily,
            argumentBufferTier: argumentBufferTier,
            unifiedMemory: device.hasUnifiedMemory,
            indirectCommandBuffers: supportsIndirectCommandBuffers,
            meshShaders: supportsMeshShaders,
            tileShaders: supportsTileShaders,
            memorylessAttachments: supportsMemorylessAttachments,
            rayTracing: device.supportsRaytracing,
            dynamicLibraries: device.supportsDynamicLibraries,
            counterSampling: [
                MTLCounterSamplingPoint.atStageBoundary,
                MTLCounterSamplingPoint.atDrawBoundary,
                MTLCounterSamplingPoint.atDispatchBoundary,
                MTLCounterSamplingPoint.atBlitBoundary,
                MTLCounterSamplingPoint.atTileDispatchBoundary
            ].contains {
                device.supportsCounterSampling($0)
            },
            maxThreadsPerThreadgroup: UInt32(
                min(maxThreadCount, UInt64(UInt32.max))),
            maxBufferLength: UInt64(device.maxBufferLength),
            maxArgumentBufferSamplerCount: UInt32(
                min(
                    UInt64(device.maxArgumentBufferSamplerCount),
                    UInt64(UInt32.max))),
            maxTextureDimension2D: 0,
            supportedSampleCounts: sampleCounts,
            maxTextureDimension2DLimit: .unknown,
            simdGroups: hasMacFamily || hasAppleFamily,
            simdGroupMatrix: device.supportsFamily(.apple7)
                || device.supportsFamily(.mac2),
            fragmentAtomics: device.supportsFamily(.mac2)
                || device.supportsFamily(.apple3),
            rayTracingMotion: device.supportsRaytracing
                && (
                    device.supportsFamily(.apple6)
                        || device.supportsFamily(.mac2)
                ),
            operatingSystemMajor: UInt32(
                min(operatingSystemVersion.majorVersion, Int(UInt32.max))
            ),
            operatingSystemMinor: UInt32(
                min(operatingSystemVersion.minorVersion, Int(UInt32.max))
            ),
            availabilitySource: "MTLDevice capability and family queries"
        )
    }
}

/// A small, headless fixture used by installed-package validation.
///
/// This lives in the wrapper rather than in a host application so an external
/// C++ consumer can prove that the packaged Swift/C++ boundary reaches a real
/// Metal render pass and a deterministic readback. It deliberately uses only
/// the baseline render-target path; capability-specific behavior belongs in
/// the runtime suites and examples.
public final class OffscreenValidationFixture {
    private init() {}

    public static func validateClearReadback(device: Device) -> Bool {
        let storageModes: [StorageMode] = [.shared, .managed]
        for storageMode in storageModes {
            guard let texture = device.createTexture(
                TextureDescriptor(
                    textureType: .twoD,
                    pixelFormat: .rgba8Unorm,
                    width: 2,
                    height: 2,
                    depth: 1,
                    arrayLength: 1,
                    mipLevelCount: 1,
                    sampleCount: 1,
                    usage: UInt32(TextureUsage.renderTarget.rawValue),
                    storageMode: storageMode,
                    cpuCacheMode: .defaultCache,
                    hazardMode: .defaultMode,
                    label: "mt installed validation target"
                )
            ),
            let queue = device.createCommandQueue(
                label: "mt installed validation queue"
            ),
            let commandBuffer = queue.makeCommandBuffer()
            else {
                continue
            }

            let pass = RenderPassDescriptor(colorTexture: texture)
            pass.clearColor = ClearColor(
                red: 1,
                green: 0,
                blue: 0,
                alpha: 1
            )
            guard let encoder = commandBuffer.makeRenderEncoder(pass),
                  encoder.endEncoding()
            else {
                continue
            }

            if storageMode == .managed {
                guard let blit = commandBuffer.makeBlitEncoder(),
                      blit.synchronize(texture),
                      blit.endEncoding()
                else {
                    continue
                }
            }

            guard commandBuffer.commit() else {
                continue
            }
            commandBuffer.waitUntilCompleted()
            guard commandBuffer.didSucceed else {
                continue
            }

            var bytes = [UInt8](repeating: 0, count: 2 * 2 * 4)
            let didRead = bytes.withUnsafeMutableBytes { rawBytes in
                texture.readBaseLevel2D(
                    destination: rawBytes.baseAddress!,
                    bytesPerRow: 2 * 4,
                    bytesPerImage: UInt64(bytes.count)
                )
            }
            guard didRead else {
                continue
            }

            let expected: [UInt8] = [255, 0, 0, 255]
            let matches = stride(from: 0, to: bytes.count, by: 4)
                .allSatisfy { index in
                    Array(bytes[index..<(index + 4)]) == expected
                }
            if matches {
                return true
            }
        }
        return false
    }
}

