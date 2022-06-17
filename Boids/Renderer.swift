//
//  Renderer.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Metal
import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    var frameIndex = 0
    
    let view: MTKView!                  // view connected to storyboard
    let device: MTLDevice!              // direct connection to GPU
    let commandQueue: MTLCommandQueue!  // ordered list of commands that you tell the GPU to execute
    let windowSize: WindowSize!
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var scene: Scene!
    
    var circle: VisionCircle
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
              
        scene = Scene(instanceCount: 40)
        let color = SIMD4<Float>(0.86, 0.86, 0.86, 0.5)
        circle = VisionCircle(mainGuy: scene.boids[0], circleSideCount: 30, radius: 0.35, color: color, device: device)
        
        super.init()
        
        buildPipeline()
        makeResources()
    }
    
    
    // create our custom rendering pipeline
    func buildPipeline() {
        // default library connects to Shaders.metal (access pre-compiled Shaders)
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexFunc = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentFunc = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride
        
        // set up render pipeline configuration
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        // Setup the output pixel format to match the pixel format of the metal kit view
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // try to make pipeline
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func makeResources() {
        
        
        
        vertexBuffer = device.makeBuffer(length: scene.boids.count * Scene.instanceDataSize, options: [])!
        scene.copyInstanceData(to: vertexBuffer)
    }
    
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        frameIndex = 0
    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        //scene.update(with: TimeInterval(1 / 60.0))
        //scene.copyInstanceData(to: vertexBuffer)
        
        

        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        
        for (i, vertexBuffer) in circle.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: i+1)
        }
        renderEncoder.drawIndexedPrimitives(type: circle.primitiveType, indexCount: circle.indexCount,
                                           indexType: circle.indexType,
                                            indexBuffer: circle.indexBuffer!,
                                           indexBufferOffset: 0)
        
        //let instanceCount = scene.boids.count + VisionCircle.sideCount
        //let vertexCount = instanceCount * 3 * VisionCircle.sideCount
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: instanceCount)   // what to draw
        
        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.addCompletedHandler { _ in
            self.frameSemaphore.signal()
        }
        commandBuffer.commit()
        frameIndex = (frameIndex + 1) % Renderer.maxFramesInFlight
    }
    
}
