
import Foundation
import Cocoa
import simd

class Shape {
    static let sideCount = 3
    static let vertexDataLength = MemoryLayout<SIMD2<Float>>.stride * 3 * sideCount
    static let instanceDataLength = MemoryLayout<SIMD2<Float>>.stride + MemoryLayout<Float>.stride + MemoryLayout<SIMD3<Float>>.stride
    
    var center: SIMD2<Float>
    var velocity: SIMD2<Float>
    var radius: Float
    var color: SIMD3<Float>
    
    init(sceneSize: SIMD2<Float>) {
        center = SIMD2<Float>(Float.random(in: 0.0..<sceneSize.x), Float.random(in: 0.0..<sceneSize.y))
        
        let angle = Float.random(in: 0.0..<(Float.pi * 2))
        let speed: Float = 80.0
        velocity = speed * SIMD2<Float>(cos(angle), sin(angle))

        radius = 30.0
        color = SIMD3<Float>(0.6, 0.9, 0.1)
    }
    
    static func copyVertexData(to buffer: MTLBuffer) {
        let vertexData = buffer.contents().bindMemory(to: Float.self, capacity: self.vertexDataLength / 4)
        
        let deltaTheta = (Float.pi * 2) / Float(sideCount)
        var i = 0
        for t in 0..<sideCount {
            let t0 = Float(t) * deltaTheta
            let t1 = Float(t + 1) * deltaTheta
            vertexData[i] = 0.0; i += 1
            vertexData[i] = 0.0; i += 1
            vertexData[i] = cos(t0); i += 1
            vertexData[i] = sin(t0); i += 1
            vertexData[i] = cos(t1); i += 1
            vertexData[i] = sin(t1); i += 1
        }
    }
}

class Scene {
    var sceneSize: SIMD2<Float>
    var shapes: [Shape]
    
    init(sceneSize: SIMD2<Float>, shapeCount: Int) {
        self.sceneSize = sceneSize
        shapes = []
        for _ in 0..<shapeCount {
            shapes.append(Shape(sceneSize: sceneSize))
        }
    }
    
    func update(with timestep: TimeInterval) {
        for s in shapes {
            s.center = s.center + (Float(timestep) * s.velocity)
            if s.center.x <= -2 {
                s.center.x = sceneSize.x+1
            }
            if s.center.y <= -2 {
                s.center.y = sceneSize.y+1
            }
            if s.center.x >= sceneSize.x+2 {
                s.center.x = -1.9
            }
            if s.center.y >= sceneSize.y+2 {
                s.center.y = -1.9
            }
        }
    }
    
    func copyInstanceData(to buffer: MTLBuffer) {
        let instanceData = buffer.contents().bindMemory(to: Float.self,
                                                        capacity: Shape.instanceDataLength / 4 * shapes.count)
        
        var i = 0
        for s in shapes {
            instanceData[i] = s.center.x; i += 1
            instanceData[i] = s.center.y; i += 1
            instanceData[i] = s.radius; i += 1
            instanceData[i] = s.color.x; i += 1
            instanceData[i] = s.color.y; i += 1
            instanceData[i] = s.color.z; i += 1
        }
    }
}
