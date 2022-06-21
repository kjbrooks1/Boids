//
//  BoidMesh.swift
//  Boids
//
//

import Foundation
import Metal
import simd

class BoidState {
  var position = SIMD3<Float>(0, 0, 0)
  var scale: Float = 1.0
  var rotationAxis = SIMD3<Float>(1, 1, 0)
  var rotationAngle: Float = 0.0
  var angularVelocity: Float = 0.0
}

class BoidMesh {
    let vertexBuffers: [MTLBuffer]
    let vertexCount: Int
    let primitiveType: MTLPrimitiveType = .triangle
    let indexBuffer: MTLBuffer?
    let indexType: MTLIndexType = .uint16
    let indexCount: Int

    init(vertexBuffers: [MTLBuffer], vertexCount: Int,
         indexBuffer: MTLBuffer, indexCount: Int)
    {
        self.vertexBuffers = vertexBuffers
        self.vertexCount = vertexCount
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
    }
}

extension BoidMesh {

    convenience init(indexedPlanarPolygonSideCount sideCount: Int, radius: Float, color: SIMD4<Float>, device: MTLDevice)
    {
        precondition(sideCount > 2)

        var positions = [SIMD2<Float>]()
        var colors = [SIMD4<Float>]()

        // makes sideCountx1 vertex data points
        var angle: Float = .pi // starting angle
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
    }
}
