//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Boid {
    
    static let width: Float  = 0.04
    static let height: Float = 2 * width
    
    var vertices: [Float]!
    var verticesDataSize: Int!
    
    var velocity: Velocity!
    
    init(winSize: WindowSize) {
        // follow rules in makeVertices func
        let startx: Float = Float.random(in: -1 ..< 1)
        let starty: Float = Float.random(in: -1 ..< 1)
        vertices = makeVertices(startX: startx, startY: starty)
        verticesDataSize = MemoryLayout<Float>.stride * vertices.count
        
        // starting velocity is randomly selected
        let angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed = Float.random(in: 10.0...50.0)
        velocity = Velocity(pos: [speed*cos(angle), speed*sin(angle)])
    }
    
    func makeVertices(startX: Float, startY: Float) -> [Float] {
        // color (RGBA) is always black
        // oddball point pos is always random to start
        // triangle size is always the same accordinng to width and height of boid
        let vertexData: [Float] = [
            //    x                     y                    r  g  b  a
            startX,                  startY,                 0, 0, 0, 1,
            startX + (Boid.width/2), startY + Boid.height,   0, 0, 0, 1,
            startX - (Boid.width/2), startY + Boid.height,   0, 0, 0, 1
        ]
        return vertexData
    }
    
    func copyVertexData(to buffer: MTLBuffer) {
        let positionData = buffer.contents().bindMemory(to: Float.self, capacity: verticesDataSize)
        for i in 0 ... self.vertices.count-1 {
            positionData[i] = self.vertices[i]
        }
    }
    
    func update(with timestep: TimeInterval) {
        
        let t = Float(timestep)
        let speedFactor: Float = 1.5
        let rotationAngle = Float(fmod(speedFactor * t, .pi * 2))
        print(cos(rotationAngle))
        
        // update y coordinates
        var posX1 = Float(vertices[0]) //+ (0.05 * cos(rotationAngle))
        var posY1 = vertices[1] + Float(0.5 * -timestep)
        // allow to wrap around view
        if posY1 < -1.2 {
            posY1 = 1.0
        }
        if posY1 > 1.2 {
            posY1 = -1.0
        }
        if posX1 < -1.2 {
            posX1 = 1.0
        }
        if posX1 > 1.2 {
            posX1 = -1.0
        }
        // update new vertices to boid
        vertices = makeVertices(startX: posX1, startY: posY1)
    }
    
}
