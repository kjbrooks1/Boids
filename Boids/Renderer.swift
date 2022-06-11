//
//  Renderer.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Metal
import MetalKit

class Renderer : NSObject, MTKViewDelegate {

    let view: MTKView!                  // view connected to storyboard
    let device: MTLDevice!              // direct connection to GPU
    let commandQueue: MTLCommandQueue!  // ordered list of commands that you tell the GPU to execute
    let windowSize: WindowSize!
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var scene: Scene!
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
                
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
        scene = Scene(instanceCount: 10)
        vertexBuffer = device.makeBuffer(length: scene.boids.count * Scene.instanceDataSize + VisionCircle.circleDataSize, options: [])!
        scene.copyInstanceData(to: vertexBuffer)
    }
    
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        
        scene.update(with: TimeInterval(1 / 60.0))
        scene.copyInstanceData(to: vertexBuffer)
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        
        
        let instanceCount = scene.boids.count + VisionCircle.sideCount
        let vertexCount = instanceCount * 3 * VisionCircle.sideCount
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: instanceCount)   // what to draw
        
        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
    
}
