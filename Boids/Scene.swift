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
            BOIDS[b].position.x = BOIDS[b].position.x + time*cos(BOIDS[b].angle)
            BOIDS[b].position.y = BOIDS[b].position.y + time*sin(BOIDS[b].angle)
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
            
            steerAway(boid: BOIDS[b])
            
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
    
    func steerAway(boid: Boid) {
        let minDistance: Float = 0.35
        for b in BOIDS {
            if(b !== boid){
                if(distance(a: boid, b: b) <= minDistance) {
                    boid.angle = boid.angle + 0.02
                }
            }
        }
    }
    
}
