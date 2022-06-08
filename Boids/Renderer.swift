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

    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
        
        super.init()
        
        buildPipeline()
        makeObjects()
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
    
    func boidCoord() -> [Vertex] {
        let width: Float = 0.05
        let height: Float = width*2
        let startx: Float = Float.random(in: -1 ... 1)
        let starty: Float = Float.random(in: -1 ... 1)
        print(startx, starty)
        return [Vertex(color: [1, 1, 1, 1], pos: [startx, starty]),
                Vertex(color: [1, 1, 1, 1], pos: [startx + (width/2), starty+height]),
                Vertex(color: [1, 1, 1, 1], pos: [startx - (width/2), starty+height])]
    }
    
    func makeObjects() {
        // Create our vertex data and buffer to go with
        let b = Boid(winSize: windowSize)
        vertexBuffer = device.makeBuffer(bytes: b.vertices, length: b.vertices.count * MemoryLayout<Vertex>.stride, options: [])!
    }
    
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2, 0.4, 0.6, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)   // what to draw

        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
    
}
