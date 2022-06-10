//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Boid {
    
    var center: SIMD2<Float>!        // [x,y]
    var vertices: [SIMD2<Float>]!    // [x,y]x3
    var velocity: SIMD2<Float>!      // [x,y]
    var color: SIMD4<Float>!         // [r, g, b, a]
    
    static let verticiesSize = 3*MemoryLayout<SIMD2<Float>>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let instanceSize = verticiesSize + colorSize
    
    init() {
        // starting velocity is randomly selected
        let angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed = Float.random(in: 1.0...5.0)
        velocity = SIMD2<Float>(speed*cos(angle), speed*sin(angle))
        
        // color is always the same
        color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0)
        
        // random center and make triangle around it
        let x: Float = Float.random(in: -1 ..< 1)
        let y: Float = Float.random(in: -1 ..< 1)
        center = SIMD2<Float>(x, y)
        vertices = makeVertices(centerX: x, centerY: y)
    }
    
    func makeVertices(centerX: Float, centerY: Float) -> [SIMD2<Float>] {
        let width: Float = 0.075
        let height: Float = 2 * width
        
        let ax = centerX - (width/2)
        let ay = centerY + (height/2)
        let bx = centerX + (width/2)
        let by = centerY + (height/2)
        let cx = centerX
        let cy = centerY - (width/2)
        
        let vert = [
            SIMD2<Float>(ax,  ay),
            SIMD2<Float>(bx,  by),
            SIMD2<Float>(cx,  cy)
        ]
        return vert
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: Boid.instanceSize)
        
        instanceData[0] = vertices[0].x
        instanceData[1] = vertices[0].y
        instanceData[2] = vertices[1].x
        instanceData[3] = vertices[1].y
        instanceData[4] = vertices[2].x
        instanceData[5] = vertices[2].y
        
    }
    
    /*
    func update(with timestep: TimeInterval) {
        vertices[0].pos.x += Float(timestep) * velocity.pos.x
        vertices[0].pos.y += Float(timestep) * velocity.pos.y
        
        vertices[1].pos.x += Float(timestep) * velocity.pos.x
        vertices[1].pos.y += Float(timestep) * velocity.pos.y
        
        vertices[2].pos.x += Float(timestep) * velocity.pos.x
        vertices[2].pos.y += Float(timestep) * velocity.pos.y
        
    }
     */
    
}
