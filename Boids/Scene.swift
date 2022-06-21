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
    fileprivate var uniformBuffer: MTLBuffer!
    var perInstanceUniforms : [PerInstanceUniforms] = []
    
    var BOIDS: [Boid]
    var boidCount: Int = 0
    var time: Float = 0
    
    init(boidCount: Int, device: MTLDevice){
        self.boidCount = boidCount
        
        BOIDS = []
        var allBoidsVertices: [Float] = []
        for _ in 0..<boidCount {
            let b = Boid()
            BOIDS.append(b)
            allBoidsVertices.append(contentsOf: b.makeBoidVertices(x: b.position.x, y: b.position.y))
            
            let ID = simd_float4x4(SIMD4<Float>(1, 0, 0, 0),
                                   SIMD4<Float>(0, 1, 0, 0),
                                   SIMD4<Float>(0, 0, 1, 0),
                                   SIMD4<Float>(0, 0, 0, 1))
            let uniform: PerInstanceUniforms = PerInstanceUniforms(transform: ID);
            perInstanceUniforms.append(uniform)
        }
        
        vertexBuffer = device.makeBuffer(bytes: allBoidsVertices, length: MemoryLayout<Float>.stride * allBoidsVertices.count, options: [.storageModeShared])
        uniformBuffer = device.makeBuffer(bytes: perInstanceUniforms, length: MemoryLayout<PerInstanceUniforms>.stride * boidCount, options: [.storageModeShared])
    }
    
    func sawToothFunc(time: Float) -> Float {
        let floor = floor((time / .pi) + 0.5)
        return 2 * ( (time / .pi) - floor )
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
    
    func draw(_ encoder: MTLRenderCommandEncoder) {
        updateUniforms()
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3*boidCount, instanceCount: boidCount)
    }
    
}

