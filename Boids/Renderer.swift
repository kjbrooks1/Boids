
import Cocoa
import Metal
import MetalKit
import simd

struct Node {
    var mesh: MTKMesh
    var modelMatrix: simd_float4x4 = matrix_identity_float4x4
}

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

    var mesh: BoidMesh
    
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
        mesh = BoidMesh(indexedPlanarPolygonSideCount: 3, radius: 0.3, color: color, device: device)
                
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
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")!
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")!
        
        renderPipelineDescriptor.rasterSampleCount = view.sampleCount
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2 // position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 // color
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
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
        for (i, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: i)
        }
        
        // add other buffers
        
        
        // do transforms
        let movementMatrix = simd_float4x4(translate2D: SIMD2<Float>(0.1, 0.1))
        let rotationMatrix = simd_float4x4(rotateZ: .pi / 2)
        var matrix = movementMatrix * rotationMatrix
        renderCommandEncoder.setVertexBytes(&matrix, length: MemoryLayout.size(ofValue: matrix), index: 2)
        
        // draw something
        renderCommandEncoder.drawIndexedPrimitives(type: mesh.primitiveType, indexCount: mesh.indexCount, indexType: mesh.indexType, indexBuffer: mesh.indexBuffer!, indexBufferOffset: 0)
        
        
        renderCommandEncoder.endEncoding()
        view.currentDrawable!.present()
        
        commandBuffer.addCompletedHandler { _ in
            self.frameSemaphore.signal()
        }
        commandBuffer.commit()
        
        frameIndex += 1
    }
}
