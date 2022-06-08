//
//  ViewController.swift
//  Boids
//
//  Created by Katherine Brooks on 6/8/22.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {

    var mtkView: MTKView!   // UI view in storyboard
    var renderer: Renderer! // code that executes each frame
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
        mtkView = mtkViewTemp
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice
        renderer = Renderer(mtkView: mtkView)
        mtkView.delegate = renderer
    }

}

