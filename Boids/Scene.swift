//
//  Swarm.swift
//  Boids
//
//

import Foundation
import MetalKit

class Scene {
    
    fileprivate var vertexBuffer: MTLBuffer!
    fileprivate var instanceBuffers: [MTLBuffer] = []
    
    var BOIDS: [Boid]
    var boidCount: Int = 0
    var visionCircle: VisionCircle
    
    
    init(boidCount: Int, device: MTLDevice){
        // init each boid
        self.boidCount = boidCount
        BOIDS = []
        for _ in 0..<boidCount {
            BOIDS.append( Boid() )
        }
        visionCircle = VisionCircle(mainGuy: BOIDS[0])
        
        // one buffer with vertex info to make single triangle at 0,0
        var shapeVerts: [Float] = []
        //shapeVerts.append(contentsOf: VisionCircle.circleVertices())
        shapeVerts.append(contentsOf: Boid.triangleVertices())
        vertexBuffer = device.makeBuffer(bytes: shapeVerts, length: MemoryLayout<Float>.stride * shapeVerts.count, options: [])
        
        // final buffer with per instance data = postion, angle
        for _ in 0..<Renderer.maxFramesInFlight {
            if let buffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 7, options: []) {
                instanceBuffers.append(buffer)
            }
        }
    }
    
    func updateInstanceData(frameIndex: Int) {
        let time = Float( TimeInterval(1 / 60.0) )
        let instanceData = instanceBuffers[frameIndex].contents().bindMemory(to: Float.self, capacity: 7*boidCount)
        
        var i = 0
        for b in 0..<boidCount {
            if(b==0) { BOIDS[b].color = SIMD4<Float>(1,0,0,1) }
            
            let seperationVector = seperation(boid: BOIDS[b]) * 0.3
            let alignmentVector = alignment(boid: BOIDS[b]) * 0.3
            BOIDS[b].velocity = simd_normalize(BOIDS[b].velocity + seperationVector + alignmentVector) * 0.5
            
            BOIDS[b].angle = atan2(BOIDS[b].velocity.y, BOIDS[b].velocity.x)
            
            BOIDS[b].position.x = BOIDS[b].position.x + time * BOIDS[b].velocity.x
            BOIDS[b].position.y = BOIDS[b].position.y + time * BOIDS[b].velocity.y
            
            if BOIDS[b].position.x >= 1.0 {
                BOIDS[b].position.x = -0.99
            }
            if BOIDS[b].position.y >= 1.0 {
                BOIDS[b].position.y = -0.99
            }
            if BOIDS[b].position.x <= -1.0 {
                BOIDS[b].position.x = 0.99
            }
            if BOIDS[b].position.y <= -1.0 {
                BOIDS[b].position.y = 0.99
            }
            
            instanceData[i] = BOIDS[b].color.x; i+=1
            instanceData[i] = BOIDS[b].color.y; i+=1
            instanceData[i] = BOIDS[b].color.z; i+=1
            instanceData[i] = BOIDS[b].color.w; i+=1
            instanceData[i] = BOIDS[b].angle; i+=1
            instanceData[i] = BOIDS[b].position.x; i+=1
            instanceData[i] = BOIDS[b].position.y; i+=1
        }
    }
    
    func draw(_ encoder: MTLRenderCommandEncoder, frameIndex: Int) {
        updateInstanceData(frameIndex: frameIndex)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(instanceBuffers[frameIndex], offset: 0, index: 2)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: boidCount)
    }
    
    // ------------------------------------------
    
    func distance(a: Boid, b: Boid) -> Float {
        return sqrt( pow((a.position.x - b.position.x), 2) + pow((a.position.y - b.position.y), 2) )
    }
    
    func seperation(boid: Boid) -> SIMD2<Float> {
        let minDistance: Float = 0.1
        var nearbyVect = SIMD2<Float>(0,0)
        for other in BOIDS {
            if(other !== boid && distance(a: boid, b: other) <= minDistance){
                nearbyVect += (other.position - boid.position)
            }
        }
        return -1 * nearbyVect
    }
    
    func alignment(boid: Boid) -> SIMD2<Float> {
        let minDistance: Float = 0.1
        var nearbyVect = SIMD2<Float>(0,0)
        var neighborCount: Float = 0
        for other in BOIDS {
            if(other !== boid && distance(a: boid, b: other) <= minDistance){
                nearbyVect += other.velocity
                neighborCount += 1
            }
        }
        if(neighborCount == 0){
            return nearbyVect
        }
        return simd_normalize(nearbyVect / neighborCount)
    }
    
}
