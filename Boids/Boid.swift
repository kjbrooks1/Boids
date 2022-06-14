//
//  Boid.swift
//  Boids
//
//  Created by Katherine Brooks on 6/14/22.
//

import Foundation
import Metal
import simd

struct stateInfo {
    // shape drawing info
    var verticesCoord: [SIMD2<Float>]
    var verticesColor: [SIMD4<Float>]
    
    // update-able info
    var center: SIMD2<Float>  // center position
    var velocity: SIMD2<Float>  // vector (x,y,z)
    var rotationAngle: Float    // radians velocity vector from x axis
}

class Boid {
    
    // buffer info
    let vertexBuffers: [MTLBuffer]
    let vertexCount: Int
    let primitiveType: MTLPrimitiveType = .triangle
    let indexBuffer: MTLBuffer?
    let indexType: MTLIndexType = .uint16
    let indexCount: Int
    let sideCount: Int = 3
    
    // shape & drawing info
    var info: stateInfo
    
    init(vertexBuffers: [MTLBuffer], vertexCount: Int, indexBuffer: MTLBuffer, indexCount: Int, info: stateInfo)
    {
        self.vertexBuffers = vertexBuffers
        self.vertexCount = vertexCount
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
        self.info = info
    }
    
    convenience init(radius: Float, color: SIMD4<Float>, device: MTLDevice)
    {
        var positions = [SIMD2<Float>]()
        var colors = [SIMD4<Float>]()

        // makes sideCountx1 vertex data points
        var angle: Float = .pi / 2 // starting angle
        let deltaAngle = (2 * .pi) / Float(3) // cover 2pi
        for _ in 0..<3 {
            positions.append(SIMD2<Float>(radius * cos(angle), radius * sin(angle)))
            colors.append(color)
            angle += deltaAngle
        }
        positions.append(SIMD2<Float>(0, 0))
        colors.append(color)

        let positionBuffer = device.makeBuffer(bytes: positions, length: MemoryLayout<SIMD2<Float>>.stride * positions.count, options: .storageModeShared)!
        positionBuffer.label = "Vertex Positions"

        let colorBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout<SIMD4<Float>>.stride * colors.count, options: .storageModeShared)!
        colorBuffer.label = "Vertex Colors"

        // this part doesn't make sense
        // at count=3 indices = [ (0,3,1) , (1,3,2), (2,3,0) ]??
        // but vertices are just 0,1,2?
        let count = UInt16(3)
        var indices = [UInt16]()
        for i in 0..<count {
            indices.append(i)
            indices.append(count)
            indices.append((i + 1) % count)
        }
        
        let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * indices.count, options: .storageModeShared)!
        indexBuffer.label = "Polygon Indices"
        
        let velocity = SIMD2<Float>(Float.random(in: 1..<5), Float.random(in: 1..<5))
        let rotationAngle = Float.random(in: 0..<2*Float.pi)
        let currInfo = stateInfo(verticesCoord: positions, verticesColor: colors, center: SIMD2<Float>(0,0), velocity: velocity, rotationAngle: rotationAngle)

        self.init(vertexBuffers: [positionBuffer, colorBuffer], vertexCount: positions.count, indexBuffer: indexBuffer, indexCount: indices.count, info: currInfo)
    }
    
    func update(with timestep: TimeInterval) {
        /*
        currentState.position += Float(timestep) * currentState.velocity
        if(currentState.position.x <= -1.1){
            currentState.position.x = 1.0
        }
        if(currentState.position.y <= -1.1){
            currentState.position.y = 1.0
        }
        if(currentState.position.x >= 1.1){
            currentState.position.x = -1.0
        }
        if(currentState.position.y >= 1.1){
            currentState.position.y = -1.0
        }
        
        var positions = [SIMD2<Float>]()
        var colors = [SIMD4<Float>]()

        // makes sideCountx1 vertex data points
        var angle: Float = .pi / 2 // starting angle
        let deltaAngle = (2 * .pi) / Float(sideCount) // cover 2pi
        for _ in 0..<sideCount {
            positions.append(SIMD2<Float>(radius * cos(angle), radius * sin(angle)))
            colors.append(color)
            angle += deltaAngle
        }
        positions.append(SIMD2<Float>(0, 0))
        colors.append(color)

        let positionBuffer = device.makeBuffer(bytes: positions, length: MemoryLayout<SIMD2<Float>>.stride * positions.count, options: .storageModeShared)!
        positionBuffer.label = "Vertex Positions"

        let colorBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout<SIMD4<Float>>.stride * colors.count, options: .storageModeShared)!
        colorBuffer.label = "Vertex Colors"

        // this part doesn't make sense
        // at count=3 indices = [ (0,3,1) , (1,3,2), (2,3,0) ]??
        // but vertices are just 0,1,2?
        let count = UInt16(sideCount)
        var indices = [UInt16]()
        for i in 0..<count {
            indices.append(i)
            indices.append(count)
            indices.append((i + 1) % count)
        }
        
        let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * indices.count, options: .storageModeShared)!
        indexBuffer.label = "Polygon Indices"

        self.init(vertexBuffers: [positionBuffer, colorBuffer], vertexCount: positions.count, indexBuffer: indexBuffer, indexCount: indices.count)
        */
        
        
    }
    
}
