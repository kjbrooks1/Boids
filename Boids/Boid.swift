//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Boid {
    
    // buffer info
    var triangleVertices: [SIMD2<Float>] = []
    var triangleColor: SIMD4<Float> = SIMD4<Float>(0.6, 0.9, 0.1, 1.0) // neon green
    var lineVerticies: [SIMD2<Float>] = []
    var lineColor: SIMD4<Float> = SIMD4<Float>(107/255,142/255,35/255, 1.0) // olive green
    var circleVerticies: [SIMD2<Float>] = []
    var circleColor: SIMD4<Float> = SIMD4<Float>(0.86, 0.86, 0.86, 1.0) // light grey
    
    // drawing & movement info
    var velocity: SIMD2<Float>      // vector [x,y]
    var center: SIMD2<Float>        // [x,y]
    var theta: Float                // velocity angle from x-asix
    var rho: Float!                 // blind angle
    
    // transformation matrices
    let translationOriginMatrix: simd_float3x3
    let rotationMatrix: simd_float3x3
    let translationBackMatrix: simd_float3x3
    
    // not done
    static let verticiesSize = 3*MemoryLayout<SIMD2<Float>>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let instanceSize = verticiesSize + colorSize
    
    init() {
        // make triangle vertices
        theta = .pi / 2  //Float.random(in: 0.0..<(Float.pi * 2))
        let x: Float = 0 //Float.random(in: -1 ..< 1)
        let y: Float = 0 //Float.random(in: -1 ..< 1)
        velocity = SIMD2<Float>(2.0 * sin(theta), 2.0 * cos(theta))
        center = SIMD2<Float>(x, y)
        
        // make matrices
        translationOriginMatrix = simd_float3x3(SIMD3<Float>( 1, 0, -x),
                                                SIMD3<Float>( 0, 1, -y),
                                                SIMD3<Float>( 0, 0,  1))
        
        rotationMatrix = simd_float3x3(SIMD3<Float>(cos(theta), -sin(theta), 0),
                                       SIMD3<Float>(sin(theta),  cos(theta), 0),
                                       SIMD3<Float>(         0,           0, 1))
        
        translationBackMatrix = simd_float3x3(SIMD3<Float>( 1, 0, x),
                                              SIMD3<Float>( 0, 1, y),
                                              SIMD3<Float>( 0, 0, 1))
        // make vertices
        triangleVertices = makeTriVertices(centerX: x, centerY: y, angleRad: theta)
        rho = calcRho()
        circleVerticies = makeCircVertices(centerX: x, centerY: y, blindAngle: rho)
        lineVerticies = makeLineVertices(centerX: x, centerY: y, angleRad: theta)
    }
    
    func makeTriVertices(centerX: Float, centerY: Float, angleRad: Float) -> [SIMD2<Float>] {
        let width: Float = 0.07
        let height: Float = 1.5 * width
        
        /*
        let ax = centerX - (width/2)
        let ay = centerY + (height/2)
        let bx = centerX + (width/2)
        let by = centerY + (height/2)
        let cx = centerX
        let cy = centerY - (width/2)
         */
        let ax = centerX - (height/2)
        let ay = centerY + (width/2)
        let bx = centerX - (height/2)
        let by = centerY - (width/2)
        let cx = centerX + (height/2)
        let cy = centerY
        
        let transformMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix
        
        let vert1 = simd_mul(SIMD3<Float>(ax,  ay, 1), transformMatrix)
        let vert2 = simd_mul(SIMD3<Float>(bx,  by, 1), transformMatrix)
        let vert3 = simd_mul(SIMD3<Float>(cx,  cy, 1), transformMatrix)
        
        return [ SIMD2<Float>(vert1.x,  vert1.y),     // vertex A
                 SIMD2<Float>(vert2.x,  vert2.y),     // vertex B
                 SIMD2<Float>(vert3.x,  vert3.y)  ]   // vertex C
    }
    
    func makeCircVertices(centerX: Float, centerY: Float, blindAngle: Float) -> [SIMD2<Float>] {
        let sideCount = 30
        var vertices: [SIMD2<Float>] = []
        let deltaTheta = (2 * Float.pi - blindAngle) / Float(sideCount)
        for t in 0 ..< sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
                 
            var transformMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix
            transformMatrix = transformMatrix * (simd_float3x3(SIMD3<Float>(cos(.pi + blindAngle / 2), -sin(.pi + blindAngle / 2), 0),
                                                               SIMD3<Float>(sin(.pi + blindAngle / 2),  cos(.pi + blindAngle / 2), 0),
                                                               SIMD3<Float>(0, 0, 1)))
            
            let vert1 = simd_mul(SIMD3<Float>(centerX, centerY, 1), transformMatrix)
            let vert2 = simd_mul(SIMD3<Float>(centerX+cos(t0)*0.4, centerY+sin(t0)*0.4, 1), transformMatrix)
            let vert3 = simd_mul(SIMD3<Float>(centerX+cos(t1)*0.4, centerY+sin(t1)*0.4, 1), transformMatrix)
            
            vertices.append(SIMD2<Float>(vert1.x,  vert1.y))
            vertices.append(SIMD2<Float>(vert2.x,  vert2.y))
            vertices.append(SIMD2<Float>(vert3.x,  vert3.y))
        }
        return vertices
    }
    
    func makeLineVertices(centerX: Float, centerY: Float, angleRad: Float) -> [SIMD2<Float>] {
        let transformMatrix = translationOriginMatrix * rotationMatrix * translationBackMatrix
        let vert1 = simd_mul(SIMD3<Float>(centerX+0.15, centerY-0.004, 1), transformMatrix)
        let vert2 = simd_mul(SIMD3<Float>(centerX+0.15, centerY+0.004, 1), transformMatrix)
        let vert3 = simd_mul(SIMD3<Float>(centerX,      centerY-0.004, 1), transformMatrix)
        let vert4 = simd_mul(SIMD3<Float>(centerX,      centerY+0.004, 1), transformMatrix)
        let vert5 = simd_mul(SIMD3<Float>(centerX+0.15, centerY+0.004, 1), transformMatrix)
        let vert6 = simd_mul(SIMD3<Float>(centerX,      centerY-0.004, 1), transformMatrix)
        
        return [ SIMD2<Float>(vert1.x,  vert1.y),
                 SIMD2<Float>(vert2.x,  vert2.y),
                 SIMD2<Float>(vert3.x,  vert3.y),
                 SIMD2<Float>(vert4.x,  vert4.y),
                 SIMD2<Float>(vert5.x,  vert5.y),
                 SIMD2<Float>(vert6.x,  vert6.y),]
    }
    
    func calcRho() -> Float {
        let A = triangleVertices[0] // A(left)
        let B = triangleVertices[1] // B(right)
        let C = center              // 'C'(head)
        
        // get side lengths
        let sideAC = round(sqrt(pow(A.x - C.x, 2) + pow(A.y - C.y, 2)) * 1000) / 1000.0
        let sideCB = round(sqrt(pow(C.x - B.x, 2) + pow(C.y - B.y, 2)) * 1000) / 1000.0
        let sideAB = round(sqrt(pow(A.x - B.x, 2) + pow(A.y - B.y, 2)) * 1000) / 1000.0
        
        // get inner angles
        //let angleA = acos((pow(sideAB, 2) + pow(sideAC, 2) - pow(sideCB, 2)) / (2 * sideAB * sideAC))
        return acos((pow(sideCB,2) + pow(sideAC,2) - pow(sideAB,2)) / (2 * sideCB * sideAC))
    }
    
}
