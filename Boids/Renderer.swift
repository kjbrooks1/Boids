//
//  Renderer.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Metal
import MetalKit

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3 // triple buffering
    // so CPU and GPU don't go at same time
    // lets us encode up to three frames, but then waits until one completes before beginning the next
    // "counting semaphore"
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    private var frameIndex: Int // keeps track of which frame we are at
    
    let view: MTKView                  // view connected to storyboard
    let device: MTLDevice!              // direct connection to GPU
    let commandQueue: MTLCommandQueue!  // ordered list of commands that you tell the GPU to execute
    let windowSize: WindowSize!
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var swarm: Swarm!
    
    private var constantsBuffer: MTLBuffer!
    private let constantsSize: Int
    private let constantsStride: Int
    private var constantsBufferOffset: Int

    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
        
        // constants buffer stores 3 frames worth of constants
        frameIndex = 0
        constantsSize = MemoryLayout<SIMD2<Float>>.size
        constantsStride = Renderer.align(constantsSize, upTo: 256) // make much bigger than necessary
        constantsBufferOffset = 0
        
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
        pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertex_main")!
        pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragment_main")!
        // Setup the output pixel format to match the pixel format of the metal kit view
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // try to make pipeline
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    func makeResources() {
        // Create our vertex data and buffer to go with
        swarm = Swarm(winSize: windowSize, boidCount: 1)
        let b: Boid = swarm.boids[0]
        // makeBuffer -> makes buffer and copies vertices all in one step
        vertexBuffer = device.makeBuffer(bytes: b.vertices, length: MemoryLayout<Float>.stride * b.vertices.count, options: .storageModeShared)
        
        // make constants buffer - used for animation (nothing in it tho)
        constantsBuffer = device.makeBuffer(length: constantsStride * Renderer.maxFramesInFlight, options: .storageModeShared)
    }
    
    func updateConstants() {
        let time = CACurrentMediaTime()
        let speedFactor = 3.0
        let rotationAngle = Float(fmod(speedFactor * time, .pi * 2))
        let rotationMagnitude: Float = 0.1
        var positionOffset = rotationMagnitude * SIMD2<Float>(cos(rotationAngle), sin(rotationAngle))
        
        constantsBufferOffset = (frameIndex % Renderer.maxFramesInFlight) * constantsStride
        let constants = constantsBuffer.contents().advanced(by: constantsBufferOffset)
        constants.copyMemory(from: &positionOffset, byteCount: constantsSize)
    }
    
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        updateConstants()
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2, 0.4, 0.6, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        //swarm.update(with: TimeInterval(1 / 60.0))
        //makeResources()
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        renderEncoder.setVertexBuffer(constantsBuffer, offset: constantsBufferOffset, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)   // what to draw

        // "submit" everything done
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.addCompletedHandler { _ in self.frameSemaphore.signal() }; frameIndex += 1
        commandBuffer.commit()
        
    }
    
}
