//
//  BoidMesh.swift
//  Boids
//
//  Created by Katherine Brooks on 6/14/22.
//

import Foundation
import Metal
import simd

class BoidMesh {
    
    let vertexBuffers: [MTLBuffer]
    let vertexDescriptor: MTLVertexDescriptor
    let vertexCount: Int
    let primitiveType: MTLPrimitiveType = .triangle
    let indexBuffer: MTLBuffer?
    let indexType: MTLIndexType = .uint16
    let indexCount: Int
    
    init(vertexBuffers: [MTLBuffer], vertexDescriptor: MTLVertexDescriptor, vertexCount: Int) {
        self.vertexBuffers = vertexBuffers
        self.vertexDescriptor = vertexDescriptor
        self.vertexCount = vertexCount
        self.indexBuffer = nil
        self.indexCount = 0
    }

    init(vertexBuffers: [MTLBuffer], vertexDescriptor: MTLVertexDescriptor, vertexCount: Int,
         indexBuffer: MTLBuffer, indexCount: Int)
    {
        self.vertexBuffers = vertexBuffers
        self.vertexDescriptor = vertexDescriptor
        self.vertexCount = vertexCount
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
    }
}

extension BoidMesh {
    
    convenience init(planarPolygonSideCount sideCount: Int, radius: Float, color: SIMD4<Float>, device: MTLDevice) {
        precondition(sideCount > 2)
        var positions = [SIMD2<Float>]()
        var colors = [SIMD4<Float>]()

        // makes sideCountx3 vertex data points
        var angle: Float = .pi / 2 // starting angle
        let deltaAngle = (2 * .pi) / Float(sideCount) // cover 2pi
        for _ in 0..<sideCount {
            positions.append(SIMD2<Float>(radius * cos(angle), radius * sin(angle)))
            colors.append(color)

            positions.append(SIMD2<Float>(radius * cos(angle + deltaAngle), radius * sin(angle + deltaAngle)))
            colors.append(color)

            positions.append(SIMD2<Float>(0, 0))
            colors.append(color)

            angle += deltaAngle
        }
        
        // fill position and color buffer
        let positionBuffer = device.makeBuffer(bytes: positions, length: MemoryLayout<SIMD2<Float>>.stride * positions.count, options: .storageModeShared)!
        positionBuffer.label = "Vertex Positions"

        let colorBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout<SIMD4<Float>>.stride * colors.count, options: .storageModeShared)!
        colorBuffer.label = "Vertex Colors"

        self.init(vertexBuffers: [positionBuffer, colorBuffer], vertexDescriptor: BoidMesh.defaultVertexDescriptor, vertexCount: positions.count)
    }

    convenience init(indexedPlanarPolygonSideCount sideCount: Int, radius: Float, color: SIMD4<Float>, device: MTLDevice)
    {
        precondition(sideCount > 2)

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

        self.init(vertexBuffers: [positionBuffer, colorBuffer], vertexDescriptor: BoidMesh.defaultVertexDescriptor, vertexCount: positions.count, indexBuffer: indexBuffer, indexCount: indices.count)
    }

    private static var defaultVertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2 // position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 // color
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<SIMD4<Float>>.stride
        return vertexDescriptor
    }
}
