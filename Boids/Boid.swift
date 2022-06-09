//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Boid {
    
    static let width: Float  = 0.075
    static let height: Float = 2 * width
    
    var vertices: [Float]!
    var velocity: Velocity!
    
    init(winSize: WindowSize) {
        // follow rules in makeVertices func
        vertices = makeVertices()
        
        // starting velocity is randomly selected
        let angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed = Float.random(in: 10.0...50.0)
        velocity = Velocity(pos: [speed*cos(angle), speed*sin(angle)])
    }
    
    func makeVertices() -> [Float] {
        let startx: Float = 0 //Float.random(in: -1 ..< 1)
        let starty: Float = 0.7 //Float.random(in: -1 ..< 1)
        
        // color (RGBA) is always black
        // oddball point pos is always random to start
        // triangle size is always the same accordinng to width and height of boid
        let vertexData: [Float] = [
            //    x                     y                    r  g  b  a
            startx,                  starty,                 0, 0, 0, 1,
            startx + (Boid.width/2), starty + Boid.height,   0, 0, 0, 1,
            startx - (Boid.width/2), starty + Boid.height,   0, 0, 0, 1
        ]
        return vertexData
    }
    
}
