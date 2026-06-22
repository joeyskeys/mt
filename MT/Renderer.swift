import MetalKit
import simd

struct Vertex {
    var position: SIMD3<Float>
}

struct Uniforms {
    var mvp: simd_float4x4
}

struct ObjectPayload {
    var meshIndex: UInt32
}

enum RendererError: LocalizedError {
    case failedToCreateCommandQueue
    case failedToCreateVertexBuffer
    case failedToCreateUniformBuffer
    case failedToCreateColorBuffer
    case failedToLoadLibrary
    case failedToFindShaderEntryPoints
    case failedToCreatePipeline(String)

    var errorDescription: String? {
        switch self {
        case .failedToCreateCommandQueue:
            return "Failed to create Metal command queue."
        case .failedToCreateVertexBuffer:
            return "Failed to create vertex buffer."
        case .failedToCreateUniformBuffer:
            return "Failed to create uniform buffer."
        case .failedToCreateColorBuffer:
            return "Failed to create color buffer."
        case .failedToLoadLibrary:
            return "Failed to load default Metal library."
        case .failedToFindShaderEntryPoints:
            return "Failed to find mesh shader entry points."
        case .failedToCreatePipeline(let detail):
            return "Failed to create mesh render pipeline: \(detail)"
        }
    }
}

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private var pipelineState: MTLRenderPipelineState!
    private let vertexBuffer: MTLBuffer
    private let uniformBuffer: MTLBuffer
    private let colorBuffer: MTLBuffer
    private let threadsPerObjectThreadgroup: Int
    private let threadsPerMeshThreadgroup: Int

    init(device: MTLDevice, view: MTKView) throws {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            throw RendererError.failedToCreateCommandQueue
        }
        self.commandQueue = queue

        let vertices: [Vertex] = [
            Vertex(position: SIMD3(0.0, 0.5, 0.0)),
            Vertex(position: SIMD3(-0.5, -0.5, 0.0)),
            Vertex(position: SIMD3(0.5, -0.5, 0.0)),
        ]

        guard let vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Vertex>.stride * vertices.count,
            options: .storageModeShared
        ) else {
            throw RendererError.failedToCreateVertexBuffer
        }
        self.vertexBuffer = vertexBuffer

        var uniforms = Uniforms(mvp: matrix_identity_float4x4)
        guard let uniformBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            options: .storageModeShared
        ) else {
            throw RendererError.failedToCreateUniformBuffer
        }
        self.uniformBuffer = uniformBuffer

        var color = SIMD4<Float>(1.0, 0.4, 0.2, 1.0)
        guard let colorBuffer = device.makeBuffer(
            bytes: &color,
            length: MemoryLayout<SIMD4<Float>>.stride,
            options: .storageModeShared
        ) else {
            throw RendererError.failedToCreateColorBuffer
        }
        self.colorBuffer = colorBuffer

        threadsPerObjectThreadgroup = 1
        threadsPerMeshThreadgroup = 3

        super.init()
        try buildPipeline(view: view)
    }

    private func buildPipeline(view: MTKView) throws {
        guard let library = device.makeDefaultLibrary() else {
            throw RendererError.failedToLoadLibrary
        }

        guard let objectFunction = library.makeFunction(name: "object_main"),
              let meshFunction = library.makeFunction(name: "mesh_main"),
              let fragmentFunction = library.makeFunction(name: "fragment_main") else {
            throw RendererError.failedToFindShaderEntryPoints
        }

        let descriptor = MTLMeshRenderPipelineDescriptor()
        descriptor.objectFunction = objectFunction
        descriptor.meshFunction = meshFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.payloadMemoryLength = MemoryLayout<ObjectPayload>.stride
        descriptor.maxTotalThreadsPerObjectThreadgroup = threadsPerObjectThreadgroup
        descriptor.maxTotalThreadsPerMeshThreadgroup = threadsPerMeshThreadgroup
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

        do {
            (pipelineState, _) = try device.makeRenderPipelineState(descriptor: descriptor, options: [])
        } catch {
            throw RendererError.failedToCreatePipeline(String(describing: error))
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let passDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setMeshBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setMeshBuffer(uniformBuffer, offset: 0, index: 1)
        encoder.setFragmentBuffer(colorBuffer, offset: 0, index: 0)
        encoder.drawMeshThreadgroups(
            MTLSize(width: 1, height: 1, depth: 1),
            threadsPerObjectThreadgroup: MTLSize(width: threadsPerObjectThreadgroup, height: 1, depth: 1),
            threadsPerMeshThreadgroup: MTLSize(width: threadsPerMeshThreadgroup, height: 1, depth: 1)
        )
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
