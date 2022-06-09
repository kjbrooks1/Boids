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
    
}
