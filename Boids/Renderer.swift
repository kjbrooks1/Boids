
import Foundation
import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3
    
    let view: MTKView
    let device: MTLDevice
    let commandQueue: MTLCommandQueue!
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    
    var renderPipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var instanceBuffers: [MTLBuffer] = []
    var frameIndex = 0
    var scene: Scene!
    
    private var constantBuffer: MTLBuffer!
    private let constantsSize: Int
    private let constantsStride: Int
    private var currentConstantBufferOffset: Int

    let mesh: BoidMesh
    
    init(view: MTKView) {
        guard let device = view.device else {
            fatalError("MTKView should be configured with a device before creating a renderer")
        }
        
        self.view = view
        self.device = device
        commandQueue = device.makeCommandQueue()!
        
        self.constantsSize = MemoryLayout<simd_float4x4>.size
        self.constantsStride = align(constantsSize, upTo: 256)
        self.currentConstantBufferOffset = 0

        let color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0)
        mesh = BoidMesh(indexedPlanarPolygonSideCount: 3, radius: 0.5, color: color, device: device)
        
        super.init()

        view.device = device
        view.delegate = self
        view.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        makePipeline()
        makeResources()
    }
    
    func makePipeline() {
        let library = device.makeDefaultLibrary()! // connect to Shader
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = mesh.vertexDescriptor
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")!
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")!
        
        renderPipelineDescriptor.rasterSampleCount = view.sampleCount
        
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }
    
    func makeResources() {
        constantBuffer = device.makeBuffer(length: constantsStride * Renderer.maxFramesInFlight, options: .storageModeShared)
        constantBuffer.label = "Dynamic Constant Buffer"
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        //scene.update(with: TimeInterval(1 / 60.0))
        //scene.copyInstanceData(to: instanceBuffers[frameIndex])
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        //renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        
        //renderCommandEncoder.setVertexBuffer(constantBuffer, offset: currentConstantBufferOffset, index: 2)
        
        // add other buffers
        for (i, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: i)
        }

        if let indexBuffer = mesh.indexBuffer {
            renderCommandEncoder.drawIndexedPrimitives(type: mesh.primitiveType, indexCount: mesh.indexCount, indexType: mesh.indexType, indexBuffer: indexBuffer, indexBufferOffset: 0)
        } else {
            renderCommandEncoder.drawPrimitives(type: mesh.primitiveType, vertexStart: 0, vertexCount: mesh.vertexCount)
        }
        
        renderCommandEncoder.endEncoding()
        view.currentDrawable!.present()
        
        commandBuffer.addCompletedHandler { _ in
            self.frameSemaphore.signal()
        }
        commandBuffer.commit()
        
        frameIndex += 1
    }
}
