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
        
        let device = MTLCreateSystemDefaultDevice()!
        
        mtkView = MTKView(frame: view.bounds, device: device)
        mtkView.sampleCount = 4
        
        mtkView.autoresizingMask = [.width, .height]
        view.addSubview(mtkView)
        
        renderer = Renderer(view: mtkView)
    }

}

