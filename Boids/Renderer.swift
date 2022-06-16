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
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
       
        super.init()
        
        buildPipeline()
        makeResources()
    }
    
    class func align(_ value: Int, upTo alignment: Int) -> Int {
        return ((value + alignment - 1) / alignment) * alignment
    }
    
    // create our custom rendering pipeline
    func buildPipeline() {
        // default library connects to Shaders.metal (access pre-compiled Shaders)
        let defaultLibrary = device.makeDefaultLibrary()
        
        // make vertex descriptor
        // position - attributes[0] - 8 bytes
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        // color - attributes[1] - 16 bytes
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.stride * 2
        vertexDescriptor.attributes[1].bufferIndex = 0
        // stride = the total number of bytes a single vertex occupies - 24 bytes
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 6

        // set up render pipeline configuration
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")!
        pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")!
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
        frameIndex = 0
    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        scene.update(with: TimeInterval(1 / 60.0))
        scene.copyInstanceData(to: vertexBuffer)
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        //swarm.update(with: TimeInterval(1 / 60.0))
        //makeResources()
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        
        
        let instanceCount = scene.boids.count + VisionCircle.sideCount
        let vertexCount = instanceCount * 3 * VisionCircle.sideCount
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: instanceCount)   // what to draw
        
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
