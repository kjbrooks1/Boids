//
//  Swarm.swift
//  Boids
//
//

import Foundation
import MetalKit

class Scene {
    
    //fileprivate var indexBuffer: MTLBuffer!
    fileprivate var vertexBuffer: MTLBuffer!
    fileprivate var instanceBuffers: [MTLBuffer] = []
    
    
    fileprivate var uniformBuffer: MTLBuffer!
    var perInstanceUniforms : [PerInstanceUniforms] = []
    
    var BOIDS: [Boid]
    var boidCount: Int = 0
    var time: Float = 0
    
    init(boidCount: Int, device: MTLDevice){
        self.boidCount = boidCount
        
        // one buffer with vertex info to make single triangle at 0,0
        var shapeVerts: [Float] = []
        shapeVerts.append(contentsOf: Boid.makeBoidVertices(x: 0, y: 0))
        vertexBuffer = device.makeBuffer(bytes: shapeVerts, length: MemoryLayout<Float>.stride * shapeVerts.count, options: [])
        
        // another buffer with per instance data = postion, angle
        for _ in 0..<Renderer.maxFramesInFlight {
            if let buffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 4, options: [.storageModeShared]) {
                instanceBuffers.append(buffer)
            }
        }
        
        // final buffer with transformation matrix
        BOIDS = []
        for _ in 0..<boidCount {
            let b = Boid()
            BOIDS.append(b)
            
            let ID = simd_float4x4(SIMD4<Float>(1, 0, 0, 0),
                                   SIMD4<Float>(0, 1, 0, 0),
                                   SIMD4<Float>(0, 0, 1, 0),
                                   SIMD4<Float>(0, 0, 0, 1))
            let uniform: PerInstanceUniforms = PerInstanceUniforms(transform: ID);
            perInstanceUniforms.append(uniform)
        }
        uniformBuffer = device.makeBuffer(bytes: perInstanceUniforms, length: MemoryLayout<PerInstanceUniforms>.stride * boidCount, options: [.storageModeShared])
    }
    
    func sawToothFunc(time: Float) -> Float {
        let floor = floor((time / .pi) + 0.5)
        return 2 * ( (time / .pi) - floor )
    }
    
    func updateInstanceData(frameIndex: Int) {
        time += 0.01
        // another buffer with per instance data = postion, angle
        var instanceData: [Float] = []
        for i in 0..<boidCount {
            instanceData.append(BOIDS[i].angle)
            instanceData.append(BOIDS[i].position.x)
            instanceData.append(BOIDS[i].position.y)
            instanceData.append(sawToothFunc(time: time))
        }
        //print(instanceData)
        instanceBuffers[frameIndex].contents().copyMemory(from: instanceData, byteCount: MemoryLayout<Float>.stride * instanceData.count)
    }
    
    func updateUniforms() {
        time += 0.01
        perInstanceUniforms = []
        for b in BOIDS {
            
            let MOVE = simd_float4x4(SIMD4<Float>(1, 0, 0, sawToothFunc(time: time)*cos(b.angle)),
                                     SIMD4<Float>(0, 1, 0, sawToothFunc(time: time)*sin(b.angle)),
                                     SIMD4<Float>(0, 0, 1, 0),
                                     SIMD4<Float>(0, 0, 0, 1))
            
            let uniform: PerInstanceUniforms = PerInstanceUniforms(transform: MOVE);
            perInstanceUniforms.append(uniform)
        }
        uniformBuffer.contents().copyMemory(from: perInstanceUniforms, byteCount: MemoryLayout<PerInstanceUniforms>.stride * boidCount)
    }
    
    func draw(_ encoder: MTLRenderCommandEncoder, frameIndex: Int) {
        updateInstanceData(frameIndex: frameIndex)
        //updateUniforms()
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(instanceBuffers[frameIndex], offset: 0, index: 1)
        //encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3*boidCount, instanceCount: boidCount)
    }
    
}

