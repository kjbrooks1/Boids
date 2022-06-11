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
    var angle: Float
    
    static let verticiesSize = 3*MemoryLayout<SIMD2<Float>>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let instanceSize = verticiesSize + colorSize
    
    init() {
        // starting velocity is randomly selected
        angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed: Float = 1.0
        velocity = SIMD2<Float>(speed*cos(angle), speed*sin(angle))
        
        // color is always the same
        color = SIMD4<Float>(0.6, 0.9, 0.1, 1.0)
        
        // random center and make triangle around it
        let x: Float = Float.random(in: -1 ..< 1)
        let y: Float = Float.random(in: -1 ..< 1)
        center = SIMD2<Float>(x, y)
        vertices = makeVertices(centerX: x, centerY: y, angleRad: angle)
    }
    
    func makeVertices(centerX: Float, centerY: Float, angleRad: Float) -> [SIMD2<Float>] {
        let width: Float = 0.05
        let height: Float = 2 * width
        let newAngleRad = angleRad + 90 * (.pi / 180)
        
        let ax = centerX - (width/2)
        let ay = centerY + (height/2)
        let bx = centerX + (width/2)
        let by = centerY + (height/2)
        let cx = centerX
        let cy = centerY - (width/2)
        
        let translationOriginMatrix = simd_float3x3( SIMD3<Float>( 1, 0, -centerX),
                                                     SIMD3<Float>( 0, 1, -centerY),
                                                     SIMD3<Float>( 0, 0,       1)  )
        
        let rotationMatrix = simd_float3x3( SIMD3<Float>(cos(newAngleRad), -sin(newAngleRad), 0),
                                            SIMD3<Float>(sin(newAngleRad),  cos(newAngleRad), 0),
                                            SIMD3<Float>(         0,           0, 1)  )
        
        let translationBackMatrix = simd_float3x3( SIMD3<Float>( 1, 0, centerX),
                                                   SIMD3<Float>( 0, 1, centerY),
                                                   SIMD3<Float>( 0, 0,       1)  )
        
        let vert0 = [
            simd_mul( SIMD3<Float>(ax,  ay, 1), translationOriginMatrix),
            simd_mul( SIMD3<Float>(bx,  by, 1), translationOriginMatrix),
            simd_mul( SIMD3<Float>(cx,  cy, 1), translationOriginMatrix)
        ]
        
        let vert1 = [
            simd_mul( vert0[0], rotationMatrix),
            simd_mul( vert0[1], rotationMatrix),
            simd_mul( vert0[2], rotationMatrix)
        ]
        
        let vert3 = [
            simd_mul( vert1[0], translationBackMatrix),
            simd_mul( vert1[1], translationBackMatrix),
            simd_mul( vert1[2], translationBackMatrix)
        ]
        
        return [ SIMD2<Float>(vert3[0].x,  vert3[0].y),
                 SIMD2<Float>(vert3[1].x,  vert3[1].y),
                 SIMD2<Float>(vert3[2].x,  vert3[2].y)  ]
    }
    
}

class VisionCircle {
    
    static let sideCount = 28
    
    static let verticiesSize = 3 * MemoryLayout<Vertex>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let circleDataSize = sideCount * 3 * MemoryLayout<Vertex>.stride
    
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var color: SIMD4<Float>
    var radius: Float
    
    init(mainGuy: Boid) {
        position = mainGuy.vertices[2]
        velocity = SIMD2<Float>(0.0, 0.0)
        color = SIMD4<Float>(0.86, 0.86, 0.86, 1.0)
        radius = 1
    }
    
}
