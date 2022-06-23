//
//  Swarm.swift
//  Boids
//
//

import Foundation
import MetalKit

class Scene {
    
    fileprivate var vertexBuffer: MTLBuffer!
    fileprivate var colorBuffer: MTLBuffer!
    fileprivate var instanceBuffers: [MTLBuffer] = []
    
    var BOIDS: [Boid]
    var boidCount: Int = 0
    var time: Float = 0
    
    init(boidCount: Int, device: MTLDevice){
        // init each boid
        self.boidCount = boidCount
        BOIDS = []
        for _ in 0..<boidCount {
            BOIDS.append( Boid() )
        }
        
        // one buffer with vertex info to make single triangle at 0,0
        var shapeVerts: [Float] = []
        shapeVerts.append(contentsOf: Boid.shapeVertices())
        vertexBuffer = device.makeBuffer(bytes: shapeVerts, length: MemoryLayout<Float>.stride * shapeVerts.count, options: [])
        
        // another buffer with color info
        var shapeColor: [Float] = []
        shapeColor.append(contentsOf: Boid.shapeColors())
        colorBuffer = device.makeBuffer(bytes: shapeColor, length: MemoryLayout<Float>.stride * shapeColor.count, options: [])
        
        // final buffer with per instance data = postion, angle
        for _ in 0..<Renderer.maxFramesInFlight {
            if let buffer = device.makeBuffer(length: MemoryLayout<Float>.stride * 4, options: []) {
                instanceBuffers.append(buffer)
            }
        }
    }
    
    func sawToothFunc(time: Float) -> Float {
        let floor = floor((time / .pi) + 0.5)
        return 2 * ( (time / .pi) - floor )
    }
    
    func updateInstanceData(frameIndex: Int) {
        time = Float( TimeInterval(1 / 60.0) )
        
        
        
        // another buffer with per instance data = postion, angle
        let instanceData = instanceBuffers[frameIndex].contents().bindMemory(to: Float.self, capacity: 4*boidCount)
        
        var i = 0
        for b in 0..<boidCount {
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
            
            instanceData[i] = BOIDS[b].angle; i+=1
            instanceData[i] = BOIDS[b].position.x; i+=1
            instanceData[i] = BOIDS[b].position.y; i+=1
        }
    }
    
    func draw(_ encoder: MTLRenderCommandEncoder, frameIndex: Int) {
        updateInstanceData(frameIndex: frameIndex)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(instanceBuffers[frameIndex], offset: 0, index: 2)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: boidCount)
    }
    
}
