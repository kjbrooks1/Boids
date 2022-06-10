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
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    
    init(view: MTKView) {
        self.view = view
        self.device = view.device
        commandQueue = device.makeCommandQueue()!
        
        super.init()
        self.view.delegate = self
        
        buildPipeline()
        makeResources()
    }
    
    // create our custom rendering pipeline
    func buildPipeline() {
        // default library connects to Shaders.metal (access pre-compiled Shaders)
        let defaultLibrary = device.makeDefaultLibrary()
        
        /* make vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4 // color
        vertexDescriptor.attributes[0].offset = MemoryLayout<Float>.stride * 2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float2 // vertex data
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 6
         */
        
        // set up render pipeline configuration
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        //pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragment_main")
        
        // try to make pipeline
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func makeResources() {
        /*
        // Create our vertex data and buffer to go with
        let b = Boid()
        vertexBuffer = device.makeBuffer(length: Boid.instanceSize, options: [.storageModeShared])!
        b.copyInstanceData(to: vertexBuffer)
         */
        var verticies: [Float] = [
            // r g b a                   x y
            0.6, 0.9, 0.1, 1.0,    -0.8,  0.4,
            0.6, 0.9, 0.1, 1.0,     0.4, -0.8,
            0.6, 0.9, 0.1, 1.0,     0.8,  0.8  ]
        vertexBuffer = device.makeBuffer(bytes: &verticies, length: MemoryLayout<Float>.stride * verticies.count, options: .storageModeShared)
    }
    
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        //renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)   // what to draw

        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
    
}
