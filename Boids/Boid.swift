//
//  Boid.swift
//  Boids
//
//

import Foundation
import MetalKit

class Boid {
    
    var vertices: [SIMD2<Float>]    = [ /*A*/SIMD2<Float>(0,0), /*B*/SIMD2<Float>(0,0), /*C*/SIMD2<Float>(0,0) ]
    var velocity: SIMD2<Float>      = SIMD2<Float>(0,0)
    var color: SIMD4<Float>         = SIMD4<Float>(0.6, 0.9, 0.1, 1.0)
    var theta: Float                = 0.0
    var rho: Float                  = 0.0
    
    var transformationMatrix: simd_float3x3!
    
    static let verticiesSize = 3*MemoryLayout<SIMD2<Float>>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let instanceSize = verticiesSize + colorSize
    
    init() {
        theta = Float.random(in: 0.0..<(Float.pi * 2))
        velocity = SIMD2<Float>(cos(theta), sin(theta))
        
        // random center and make triangle around it
        let x: Float = Float.random(in: -1 ..< 1)
        let y: Float = Float.random(in: -1 ..< 1)
        
        let translationOriginMatrix = simd_float3x3( SIMD3<Float>( 1, 0, -x),
                                                     SIMD3<Float>( 0, 1, -y),
                                                     SIMD3<Float>( 0, 0,       1)  )
        
        let rotationMatrix = simd_float3x3( SIMD3<Float>(cos(theta + 90 * (.pi / 180)), -sin(theta + 90 * (.pi / 180)), 0),
                                            SIMD3<Float>(sin(theta + 90 * (.pi / 180)),  cos(theta + 90 * (.pi / 180)), 0),
                                            SIMD3<Float>(         0,           0, 1)  )
        
        let translationBackMatrix = simd_float3x3( SIMD3<Float>( 1, 0, x),
                                                   SIMD3<Float>( 0, 1, y),
                                                   SIMD3<Float>( 0, 0,       1)  )
        
        transformationMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix

        
        vertices = makeVertices(centerX: x, centerY: y, angleRad: theta, transMatrix: transformationMatrix)
        rho = calcRho()
    }
    
    func makeVertices(centerX: Float, centerY: Float, angleRad: Float, transMatrix: simd_float3x3) -> [SIMD2<Float>] {
        let temp = [
            simd_mul( SIMD3<Float>(centerX - 0.1 * cos(.pi/2.5),  centerY + 0.1 * sin(.pi/2.5), 1), transMatrix),
            simd_mul( SIMD3<Float>(centerX + 0.1 * cos(.pi/2.5),  centerY + 0.1 * sin(.pi/2.5), 1), transMatrix),
            simd_mul( SIMD3<Float>(centerX,  centerY, 1), transMatrix)
        ]
        
        return [ SIMD2<Float>(temp[0].x,  temp[0].y),     // vertex A
                 SIMD2<Float>(temp[1].x,  temp[1].y),     // vertex B
                 SIMD2<Float>(temp[2].x,  temp[2].y)  ]   // vertex C
    }
    
    func calcRho() -> Float {
        let A = vertices[0] // A(left)
        let B = vertices[1] // B(right)
        let C = vertices[2] // C(head)
        
        // get side lengths
        let sideAC = round(sqrt(pow(A.x - C.x, 2) + pow(A.y - C.y, 2)) * 1000) / 1000.0
        let sideCB = round(sqrt(pow(C.x - B.x, 2) + pow(C.y - B.y, 2)) * 1000) / 1000.0
        let sideAB = round(sqrt(pow(A.x - B.x, 2) + pow(A.y - B.y, 2)) * 1000) / 1000.0
        
        // get inner angles
        //angleA = acos((pow(sideAB, 2) + pow(sideAC, 2) - pow(sideCB, 2)) / (2 * sideAB * sideAC))
        return acos((pow(sideCB,2) + pow(sideAC,2) - pow(sideAB,2)) / (2 * sideCB * sideAC))
    }
}

