//
//  Swarm.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Foundation
import MetalKit

class Swarm {
    
    var winSize: WindowSize
    var boids: [Boid]
    
    init(winSize: WindowSize, boidCount: Int){
        self.winSize = winSize
        boids = []
        for _ in 0 ..< boidCount {
            boids.append(Boid(winSize: self.winSize))
        }
    }
    
    func update(with timestep: TimeInterval) {
        /*
        for b in boids {
            // update positions
            let org_pos: [Vertex] = b.vertices
            let movementX = (Float(timestep) * b.velocity.pos.x)
            let movementY = (Float(timestep) * b.velocity.pos.y)
            b.vertices = [Vertex(color: [0, 0, 0, 1], pos: [org_pos[0].pos.x + movementX, org_pos[0].pos.y] + movementY),
                          Vertex(color: [0, 0, 0, 1], pos: [org_pos[1].pos.x + movementX, org_pos[1].pos.y] + movementY),
                          Vertex(color: [0, 0, 0, 1], pos: [org_pos[2].pos.x + movementX, org_pos[2].pos.y] + movementY)]
            // if new position is out of bounds
            // allow to wrap around window
            if b.vertices[0].pos.x <= 0.0 {
                b.vertices[0].pos.x = winSize.size.x
            }
            if b.vertices[0].pos.y <= 0.0 {
                b.vertices[0].pos.y = winSize.size.y
            }
            if b.vertices[0].pos.x >= winSize.size.x {
                b.vertices[0].pos.x = 0.0
            }
            if b.vertices[0].pos.y >= winSize.size.y {
                b.vertices[0].pos.y = 0.0
            }
        }
         */
    }
    
}
