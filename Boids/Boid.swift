//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit


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
        let x: Float = 0 //Float.random(in: -1 ..< 1)
        let y: Float = 0 //Float.random(in: -1 ..< 1)
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
        print(vert)
        return vert
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        let vert2 = makeVertices(centerX: 0.5, centerY: 0.5)
        let test = [Vertex(color: color, pos: vertices[0]),
                    Vertex(color: color, pos: vertices[1]),
                    Vertex(color: color, pos: vertices[2]),
                    Vertex(color: color, pos: vert2[0]),
                    Vertex(color: color, pos: vert2[1]),
                    Vertex(color: color, pos: vert2[2]),]
        print(test)
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: test.count * MemoryLayout<Vertex>.stride)
        memcpy(instanceData, test, test.count * MemoryLayout<Vertex>.stride)
        
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
