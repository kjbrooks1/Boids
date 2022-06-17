//
//  VisionCircle.swift
//  Boids
//
//  Created by Katherine Brooks on 6/17/22.
//

import Foundation
import MetalKit

class VisionCircle {
    
    // memory size info
    static let sideCount = 40
    static let verticiesSize = 3 * MemoryLayout<Vertex>.stride
    static let colorSize = MemoryLayout<SIMD3<Float>>.stride
    static let circleDataSize = sideCount * 3 * MemoryLayout<Vertex>.stride
    
    // mesh info
    let vertexBuffers: [MTLBuffer]
    let vertexCount: Int
    let primitiveType: MTLPrimitiveType = .triangle
    let indexBuffer: MTLBuffer?
    let indexType: MTLIndexType = .uint16
    let indexCount: Int
    
    init(vertexBuffers: [MTLBuffer], vertexCount: Int, indexBuffer: MTLBuffer, indexCount: Int)
    {
        self.vertexBuffers = vertexBuffers
        self.vertexCount = vertexCount
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
    }
    
    /*
    init(mainGuy: Boid) {
        self.mainGuy = mainGuy
        center = mainGuy.vertices[2]
        
        indices = [UInt16]()
        let count = UInt16(VisionCircle.sideCount)
        for i in 0..<count {
            indices.append(i)
            indices.append(count)
            indices.append((i + 1) % count)
        }
        indexCount = indices.count
        vertices = makeVertices(mainGuy: mainGuy, transMatrix: mainGuy.transformationMatrix)
    }
     
    
    func makeVertices(mainGuy: Boid, transMatrix: simd_float3x3) -> [SIMD2<Float>] {
        var allVert: [SIMD2<Float>] = []
        center = mainGuy.vertices[2]
        
        let blindAngle = mainGuy.rho
        let deltaTheta = (2 * Float.pi - blindAngle) / Float(VisionCircle.sideCount)
        var angle: Float = 0.0
        for _ in 0..<VisionCircle.sideCount {
            let temp = simd_mul( SIMD3<Float>(center.x+cos(angle + .pi / 2 + blindAngle / 2)*0.35, center.y+sin(angle + .pi / 2 + blindAngle / 2)*0.35, 1), transMatrix)
            allVert.append(SIMD2<Float>(temp.x, temp.y))
            angle += deltaTheta
        }
        allVert.append(SIMD2<Float>(center.x, center.y))
        return allVert
    }
     */
}

extension VisionCircle {
    
    convenience init(mainGuy: Boid, circleSideCount sideCount: Int, radius: Float, color: SIMD4<Float>, device: MTLDevice) {
        precondition(sideCount > 2)
        
        var vertices = [SIMD2<Float>]()
        var colors = [SIMD4<Float>]()
        let center = SIMD2<Float>(0, 0)
        
        var angle: Float = .pi / 2
        let deltaAngle = (2 * .pi - mainGuy.rho) / Float(sideCount)
        for _ in 0..<sideCount {
            vertices.append(SIMD2<Float>(center.x + 0.3 * cos(angle + .pi/2 + mainGuy.rho/2), center.y + 0.3 * sin(angle + .pi/2 + mainGuy.rho/2)))
            colors.append(color)

            angle += deltaAngle
        }
        vertices.append(SIMD2<Float>(0, 0))
        colors.append(color)
        
        let verticesBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<SIMD2<Float>>.stride * vertices.count, options: .storageModeShared)!
        verticesBuffer.label = "Vertex Positions"

        let colorBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout<SIMD4<Float>>.stride * colors.count, options: .storageModeShared)!
        colorBuffer.label = "Vertex Colors"
        
        let count = UInt16(sideCount)
        var indices = [UInt16]()
        for i in 0..<count {
            indices.append(i)
            indices.append(count)
            indices.append((i + 1) % count)
        }

        let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * indices.count, options: .storageModeShared)!
        indexBuffer.label = "Polygon Indices"

        self.init(vertexBuffers: [verticesBuffer, colorBuffer],
                  vertexCount: vertices.count,
                  indexBuffer: indexBuffer,
                  indexCount: indices.count)
    }
}
