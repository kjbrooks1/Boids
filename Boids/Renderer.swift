//
//  Renderer.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Metal
import MetalKit

struct FrameData {
    var distanceX: Float
    var distanceY: Float
    var angleRad: Float
}

class Renderer : NSObject, MTKViewDelegate {
    static let maxFramesInFlight = 3
    let frameSemaphore = DispatchSemaphore(value: Renderer.maxFramesInFlight)
    var frameIndex = 0
    var frameBuffers: [MTLBuffer] = []
    var allFrameData: [FrameData] = []
    var time: Float = 0.0
    
    let view: MTKView!                  // view connected to storyboard
    let device: MTLDevice!              // direct connection to GPU
    let commandQueue: MTLCommandQueue!  // ordered list of commands that you tell the GPU to execute
    let windowSize: WindowSize!
    
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    
    var BOIDS: [Boid] = []
    var boidCount: Int = 0
    
    var allVerticesCount: Int = 0
    var allVerticesSize: Int = 0
    
    init(mtkView: MTKView) {
        view = mtkView
        device = mtkView.device
        commandQueue = device.makeCommandQueue()
        windowSize = WindowSize(size: [Float(view.drawableSize.width), Float(view.drawableSize.height)])
        
        super.init()
        
        buildPipeline()
        buildResources()
        buildFrameData()
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
    
    func buildResources() {
        boidCount = 2
        var allVertices: [Float] = []
        BOIDS = []
        for _ in 0..<boidCount {
            let boid = Boid()
            BOIDS.append(boid)
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
            
            allVerticesCount += (boid.triangleVertices.count + boid.lineVerticies.count + boid.circleVerticies.count)
            allVerticesSize += Int(2 * allVerticesCount * MemoryLayout<SIMD4<Float>>.stride)
        }
        vertexBuffer = device.makeBuffer(bytes: allVertices, length: allVerticesSize, options: [])
    }
    
    func buildFrameData() {
        frameBuffers = []
        let frameDataSize = Renderer.maxFramesInFlight * boidCount * MemoryLayout<FrameData>.stride
        for _ in 0..<Renderer.maxFramesInFlight {
            if let buffer = device.makeBuffer(length: frameDataSize, options: [.storageModeShared]) {
                frameBuffers.append(buffer)
            }
        }
    }
    
    // automatically called whenever the view size changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func sawToothFunc(time: Float, speed: Float) -> Float {
        let newTime = time + .pi
        let floorPart = floor((newTime / .pi) + 0.5)
        return 2 * ( (newTime / .pi) - floorPart )
    }
    
    // automatically called to render new content
    func draw(in view: MTKView) {
        frameSemaphore.wait()
        
        time += Float(TimeInterval(1 / 60.0))
        allFrameData = []
        for i in 0..<boidCount {
            print(i)
            let frameData = FrameData(distanceX: sawToothFunc(time: time, speed: BOIDS[i].velocity.x), distanceY: sawToothFunc(time: time, speed: BOIDS[i].velocity.y), angleRad: BOIDS[i].theta)
            allFrameData.append(FrameData(distanceX: sawToothFunc(time: time, speed: BOIDS[i].velocity.x), distanceY: sawToothFunc(time: time, speed: BOIDS[i].velocity.x), angleRad: BOIDS[i].theta)) // something wrong with angleRad....
            //memcpy(frameBuffers[frameIndex], frameData, MemoryLayout<FrameData>.stride)
        }
        print("bcount=",boidCount)
        print(allFrameData)
        print("----------")
        frameBuffers[frameIndex].contents().copyMemory(from: &allFrameData, byteCount: MemoryLayout<FrameData>.stride * allFrameData.count)
        
        /*
         shader_types::InstanceData* pInstanceData = reinterpret_cast< shader_types::InstanceData *>( pInstanceDataBuffer->contents() );
         for ( size_t i = 0; i < kNumInstances; ++i )
         {
             float iDivNumInstances = i / (float)kNumInstances;
             float xoff = (iDivNumInstances * 2.0f - 1.0f) + (1.f/kNumInstances);
             float yoff = sin( ( iDivNumInstances + _angle ) * 2.0f * M_PI);
             pInstanceData[ i ].instanceTransform = (float4x4){ (float4){ scl * sinf(_angle), scl * cosf(_angle), 0.f, 0.f },
                                                                (float4){ scl * cosf(_angle), scl * -sinf(_angle), 0.f, 0.f },
                                                                (float4){ 0.f, 0.f, scl, 0.f },
                                                                (float4){ xoff, yoff, 0.f, 1.f } };

             float r = iDivNumInstances;
             float g = 1.0f - r;
             float b = sinf( M_PI * 2.0f * iDivNumInstances );
             pInstanceData[ i ].instanceColor = (float4){ r, g, b, 1.0f };
         }
         pInstanceDataBuffer->didModifyRange( NS::Range::Make( 0, pInstanceDataBuffer->length() ) );


         */
        // clearing the screen
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1) // set bg color
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // encode drawing commands -> draw triangle
        renderEncoder.setRenderPipelineState(pipelineState)                 // what render pipeline to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)    // what vertex buff to use
        renderEncoder.setVertexBuffer(frameBuffers[frameIndex], offset: 0, index: 1) // what frame buff to use
        
        // actually draw the stuff
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: allVerticesCount, instanceCount: boidCount)
        
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
