//
//  Renderer.swift
//  Boids
//
//

import Metal
import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    var frameIndex = 0
    
    let view: MTKView!                          // view connected to storyboard
    let device: MTLDevice!                      // direct connection to GPU
    let commandQueue: MTLCommandQueue!          // ordered list of commands that you tell the GPU to execute
    var pipelineState: MTLRenderPipelineState!  // renderer pipeline
    let scene: Scene
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        scene = Scene(boidCount: 10, device: device)
        
        super.init()
        
        buildPipeline()
    }
    
    
    // create our custom rendering pipeline
    func buildPipeline() {
        // default library connects to Shaders.metal (access pre-compiled Shaders)
        let defaultLibrary = device.makeDefaultLibrary()
        
        // vertex info
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2 // (x,y)
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 // color
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stepRate = 1
        
        // per instance
        vertexDescriptor.attributes[2].format = .float // angle
        vertexDescriptor.attributes[2].offset = 0
        vertexDescriptor.attributes[2].bufferIndex = 1
        
        vertexDescriptor.attributes[3].format = .float // position.x
        vertexDescriptor.attributes[3].offset = MemoryLayout<Float>.stride
        vertexDescriptor.attributes[3].bufferIndex = 1
        
        vertexDescriptor.attributes[4].format = .float // position.y
        vertexDescriptor.attributes[4].offset = MemoryLayout<Float>.stride * 2
        vertexDescriptor.attributes[4].bufferIndex = 1
        
        vertexDescriptor.attributes[5].format = .float // time element
        vertexDescriptor.attributes[5].offset = MemoryLayout<Float>.stride * 3
        vertexDescriptor.attributes[5].bufferIndex = 1

        vertexDescriptor.layouts[1].stride = MemoryLayout<Float>.stride * 4
        vertexDescriptor.layouts[1].stepFunction = .perInstance
        vertexDescriptor.layouts[1].stepRate = 1
        
        // set up render pipeline configuration
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // try to make pipeline
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        frameIndex = 0
    }
    
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // draw
        scene.draw(renderEncoder, frameIndex: frameIndex)
        
        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        commandBuffer.addCompletedHandler { _ in
            self.frameSemaphore.signal()
        }
        frameIndex = (frameIndex + 1) % Renderer.maxFramesInFlight
    }
    
}
