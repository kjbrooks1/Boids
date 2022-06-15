//
//  Swarm.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

/*
class Scene {
    
    var boids: [Boid]
    var circle: VisionCircle
    static let instanceDataSize = 3 * MemoryLayout<Vertex>.stride
    
    init(instanceCount: Int){
        boids = []
        for _ in 0..<instanceCount {
            boids.append(Boid())
        }
        circle = VisionCircle(mainGuy: boids[0])
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        // get the vertex data from each boid
        var j = 0
        var test: [Vertex] = []
        
        // arccos((P122 + P132 - P232) / (2 * P12 * P13))
        // sqrt((P1x - P2x)2 + (P1y - P2y)2)
        
        /*let P1x = boids[0].vertices[0].x; let P1y = boids[0].vertices[0].y
        let P2x = boids[1].vertices[1].x; let P2y = boids[1].vertices[1].y
        let P3x = boids[2].vertices[2].x; let P3y = boids[2].vertices[2].y
        
        let P12 = sqrt(pow((P1x - P2x),2)) + pow((P1y - P2y),2)
        let P13 = sqrt(pow((P1x - P3x),2)) + pow((P1y - P3y),2)
        let P23 = sqrt(pow((P2x - P3x),2)) + pow((P2y - P3y),2)
        //print("------\n")
        //print(P12, P13, P23)
        let angleeee = cosh( (pow(P12,2) + pow(P13,2) + pow(P23, 2)) / (2 * P12 * P13)  )
        print(angleeee)
         */
        
        let angle = boids[0].angleC
        
        let deltaTheta = (2 * Float.pi - angle) / Float(VisionCircle.sideCount)
        for t in 0..<VisionCircle.sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
                 
            let translationOriginMatrix = simd_float3x3( SIMD3<Float>( 1, 0, -boids[0].center.x),
                                                         SIMD3<Float>( 0, 1, -boids[0].center.y),
                                                         SIMD3<Float>( 0, 0,       1)  )
            
            let rotationMatrix = simd_float3x3( SIMD3<Float>(cos(boids[0].angle + boids[0].angleC / 2 + .pi), -sin(boids[0].angle + boids[0].angleC / 2 + .pi), 0),
                                                SIMD3<Float>(sin(boids[0].angle + boids[0].angleC / 2 + .pi),  cos(boids[0].angle + boids[0].angleC / 2 + .pi), 0),
                                                SIMD3<Float>(         0,           0, 1)  )
            
            let translationBackMatrix = simd_float3x3( SIMD3<Float>( 1, 0, boids[0].center.x),
                                                       SIMD3<Float>( 0, 1, boids[0].center.y),
                                                       SIMD3<Float>( 0, 0,       1)  )
            
            let vert0 = [
                simd_mul( SIMD3<Float>(circle.position.x, circle.position.y, 1), translationOriginMatrix),
                simd_mul( SIMD3<Float>(circle.position.x+cos(t0)*0.35, circle.position.y+sin(t0)*0.35, 1), translationOriginMatrix),
                simd_mul( SIMD3<Float>(circle.position.x+cos(t1)*0.35, circle.position.y+sin(t1)*0.35, 1), translationOriginMatrix)
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
            
                                       
            //simd_mul( SIMD3<Float>(ax,  ay, 1), translationOriginMatrix),
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(circle.position.x, circle.position.y) ))
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(vert3[1].x, vert3[1].y) ))
            test.append(Vertex(color: circle.color, pos: SIMD2<Float>(vert3[2].x, vert3[2].y) ))
        }
        
        for b in boids {
            if (j == 0) { b.color = SIMD4<Float>(1.0, 0.0, 0.0, 1.0) }
            test.append(Vertex(color: b.color, pos: b.vertices[0]))
            test.append(Vertex(color: b.color, pos: b.vertices[1]))
            test.append(Vertex(color: b.color, pos: b.vertices[2]))
            j += 1
        }
        
        
        
        // copy over to vertex buffer
        let instanceData = buffer.contents().bindMemory(to: Float.self, capacity: boids.count * Scene.instanceDataSize + VisionCircle.circleDataSize)
        memcpy(instanceData, test, boids.count * Scene.instanceDataSize + VisionCircle.circleDataSize)
    }
    
    func update(with timestep: TimeInterval) {
        var i = 0
        for b in boids {
            b.center.x = b.center.x + (Float(timestep) * b.velocity.x)
            b.center.y = b.center.y + (Float(timestep) * b.velocity.y)
            b.vertices = b.makeVertices(centerX: b.center.x, centerY: b.center.y, angleRad: b.angle)
            if (i == 0) {
                b.color = SIMD4<Float>(1.0, 0.0, 0.0, 1.0)
                circle.position = b.vertices[2]
            }
            if b.center.x <= -1.2 {
                b.center.x = 1.0
            }
            if b.center.y <= -1.2 {
                b.center.y = 1.0
            }
            if b.center.x >= 1.2 {
                b.center.x = -1.0
            }
            if b.center.y >= 1.2 {
                b.center.y = -1.0
            }
            i += 1
        }
    }
    
}
 */
