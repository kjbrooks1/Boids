//
//  Renderer.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Metal
import MetalKit

struct FrameData {
    var distance: Float
    //float angle;
}

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    var frameIndex = 0
    var frameData: [MTLBuffer] = []
    var distance: Float = 0.0
    var time: Float = 0.0
    
    let view: MTKView!                  // view connected to storyboard
    let device: MTLDevice!              // direct connection to GPU
    let commandQueue: MTLCommandQueue!  // ordered list of commands that you tell the GPU to execute
    let windowSize: WindowSize!
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var boid: Boid!
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
                
        super.init()
        
        buildPipeline()
        buildFrameData()
        makeResources()
    }
    
    
    // create our custom rendering pipeline
    func buildPipeline() {
        // default library connects to Shaders.metal (access pre-compiled Shaders)
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexFunc = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentFunc = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2 // position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 // color
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        
        // set up render pipeline configuration
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        // Setup the output pixel format to match the pixel format of the metal kit view
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // try to make pipeline
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func buildFrameData() {
        frameData = []
        for _ in 0..<Renderer.maxFramesInFlight {
            if let buffer = device.makeBuffer(length: MemoryLayout<FrameData>.stride, options: [.storageModeShared]) {
                frameData.append(buffer)
            }
        }
    }
    
    func makeResources() {
        boid = Boid()
        var allVertices: [Float] = []
        
        // draw circle
        for a in 0..<boid.circleVerticies.count {
            allVertices.append(boid.circleVerticies[a].x)
            allVertices.append(boid.circleVerticies[a].y)
            allVertices.append(0.0) // padding
            allVertices.append(0.0) // padding
            allVertices.append(boid.circleColor.x)
            allVertices.append(boid.circleColor.y)
            allVertices.append(boid.circleColor.z)
            allVertices.append(boid.circleColor.w)
        }
        
        // draw line
        for a in 0..<boid.lineVerticies.count {
            allVertices.append(boid.lineVerticies[a].x)
            allVertices.append(boid.lineVerticies[a].y)
            allVertices.append(0.0) // padding
            allVertices.append(0.0) // padding
            allVertices.append(boid.lineColor.x)
            allVertices.append(boid.lineColor.y)
            allVertices.append(boid.lineColor.z)
            allVertices.append(boid.lineColor.w)
        }
        
        // draw triangle
        for a in 0..<boid.triangleVertices.count {
            allVertices.append(boid.triangleVertices[a].x)
            allVertices.append(boid.triangleVertices[a].y)
            allVertices.append(0.0) // padding
            allVertices.append(0.0) // padding
            allVertices.append(boid.triangleColor.x)
            allVertices.append(boid.triangleColor.y)
            allVertices.append(boid.triangleColor.z)
            allVertices.append(boid.triangleColor.w)
        }
        let count: Int = (boid.triangleVertices.count + boid.lineVerticies.count + boid.circleVerticies.count)
        let allVerticesSize: Int = Int(2 * count * MemoryLayout<SIMD4<Float>>.stride)
        
        vertexBuffer = device.makeBuffer(bytes: allVertices, length: allVerticesSize, options: [])
    }
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        // frame data = stuff to change center position
        // update vertex buffer with new center position & vertices
        frameIndex = (frameIndex + 1) % Renderer.maxFramesInFlight
        time += Float(TimeInterval(1 / 60.0))
        
        let timeBoxed = (time).truncatingRemainder(dividingBy: (2 * Float.pi))
        print(timeBoxed)
        if(0 < timeBoxed && timeBoxed <= .pi / 2){
            // use sin
            distance = sin(time)
        }
        else if(.pi/2 < timeBoxed && timeBoxed < 3 * .pi / 2){
            // use cos
            distance = cos(time + .pi / 2)
        }
        else if(3 * .pi / 2 < timeBoxed && timeBoxed <= 2 * .pi){
            // sin sin
            distance = sin(time)
        }
        
        frameData[frameIndex].contents().copyMemory(from: &distance, byteCount: MemoryLayout<Float>.stride)
        //reinterpret_cast< FrameData * >( pFrameDataBuffer->contents() )->angle = (_angle += 0.01f);
        
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use

        renderEncoder.setVertexBuffer(frameData[frameIndex], offset: 0, index: 1)
        
        // set movement matrix to make everything move together
        /*
        var projectionMatrix = simd_float4x4(SIMD4<Float>(1, 0, 0, Float(3*TimeInterval(1 / 60.0))),
                                             SIMD4<Float>(0, 1, 0, Float(3*TimeInterval(1 / 60.0))),
                                             SIMD4<Float>(0, 0, 1, 0),
                                             SIMD4<Float>(0, 0, 0, 1))
        renderEncoder.setVertexBytes(&projectionMatrix, length: MemoryLayout.size(ofValue: projectionMatrix), index: 2)
        */
        
        let instanceCount = 4
        let vertexCount = boid.circleVerticies.count + boid.triangleVertices.count + boid.lineVerticies.count
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
