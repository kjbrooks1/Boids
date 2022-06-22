//
//  Boid.swift
//  Boids
//
//

import Foundation
import MetalKit

class Boid {
    
    var center: SIMD2<Float>         // [x,y]
    var vertices: [SIMD2<Float>]!    // A(left), B(right), C(head)
    var velocity: SIMD2<Float>!      // [x,y]
    var color: SIMD4<Float>!         // [r, g, b, a]
    var angle: Float
    
    var sideAC: Float = 0
    var sideCB: Float = 0
    var sideAB: Float = 0
    var angleA: Float = 0
    var angleB: Float = 0
    var angleC: Float = 0
    
    var transformationMatrix: simd_float3x3!
    
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
        
        let translationOriginMatrix = simd_float3x3( SIMD3<Float>( 1, 0, -x),
                                                     SIMD3<Float>( 0, 1, -y),
                                                     SIMD3<Float>( 0, 0,       1)  )
        
        let rotationMatrix = simd_float3x3( SIMD3<Float>(cos(angle + 90 * (.pi / 180)), -sin(angle + 90 * (.pi / 180)), 0),
                                            SIMD3<Float>(sin(angle + 90 * (.pi / 180)),  cos(angle + 90 * (.pi / 180)), 0),
                                            SIMD3<Float>(         0,           0, 1)  )
        
        let translationBackMatrix = simd_float3x3( SIMD3<Float>( 1, 0, x),
                                                   SIMD3<Float>( 0, 1, y),
                                                   SIMD3<Float>( 0, 0,       1)  )
        transformationMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix

        
        vertices = makeVertices(centerX: x, centerY: y, angleRad: angle, transMatrix: transformationMatrix)
        fillTriangleData()
    }
    
    func makeVertices(centerX: Float, centerY: Float, angleRad: Float, transMatrix: simd_float3x3) -> [SIMD2<Float>] {        
        let ax = centerX - 0.1 * cos(.pi/2.5)
        let ay = centerY + 0.1 * sin(.pi/2.5)
        let bx = centerX + 0.1 * cos(.pi/2.5)
        let by = centerY + 0.1 * sin(.pi/2.5)
        let cx = centerX
        let cy = centerY
        
        
        let temp = [
            simd_mul( SIMD3<Float>(ax,  ay, 1), transMatrix),
            simd_mul( SIMD3<Float>(bx,  by, 1), transMatrix),
            simd_mul( SIMD3<Float>(cx,  cy, 1), transMatrix)
        ]
        
        return [ SIMD2<Float>(temp[0].x,  temp[0].y),     // vertex A
                 SIMD2<Float>(temp[1].x,  temp[1].y),     // vertex B
                 SIMD2<Float>(temp[2].x,  temp[2].y)  ]   // vertex C
    }
    
    func fillTriangleData() {
        let A = vertices[0] // A(left)
        let B = vertices[1] // B(right)
        let C = center // C(head)
        
        // get side lengths
        sideAC = round(sqrt(pow(A.x - C.x, 2) + pow(A.y - C.y, 2)) * 1000) / 1000.0
        sideCB = round(sqrt(pow(C.x - B.x, 2) + pow(C.y - B.y, 2)) * 1000) / 1000.0
        sideAB = round(sqrt(pow(A.x - B.x, 2) + pow(A.y - B.y, 2)) * 1000) / 1000.0
        
        // get inner angles
        angleA = acos((pow(sideAB, 2) + pow(sideAC, 2) - pow(sideCB, 2)) / (2 * sideAB * sideAC))
        angleC = acos((pow(sideCB,2) + pow(sideAC,2) - pow(sideAB,2)) / (2 * sideCB * sideAC))
        angleB = Float.pi - angleA - angleC
    }
    
}


