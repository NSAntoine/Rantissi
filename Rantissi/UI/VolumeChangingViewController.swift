//
//  VolumeChangingViewController.swift
//  Rantissi
//
//  Created by Serena on 26/07/2023.
//

import Cocoa
import class SwiftUI.NSHostingView

// A Stub as a View Controller to show the actual view
class VolumeChangingViewController: NSViewController {
    
    override func loadView() {
        view = NSView()
        
        view.frame = NSScreen.main!.visibleFrame
    }
    
    let volumeObserverView = VolumeObserverView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(volumeObserverView)
        volumeObserverView.translatesAutoresizingMaskIntoConstraints = false
        
//        let trailing = volumeObserverView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
            volumeObserverView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            volumeObserverView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            volumeObserverView.widthAnchor.constraint(equalToConstant: 340),
            volumeObserverView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Animate view from invisible to visible
        volumeObserverView.animator().alphaValue = 0
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            
        } completionHandler: {
            self.volumeObserverView.animator().alphaValue = 1
        }
            
//        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: volumeObserverView, queue: nil) { notif in
//            if initiallyChangeFrame {
//                initiallyChangeFrame = false
//                
//                NSAnimationContext.runAnimationGroup { context in
//                    context.duration = 0.25
//                    context.timingFunction = .init(name: .linear)
//                    context.allowsImplicitAnimation = true
//                    
//                    // The view will animate to the new origin
//                    (notif.object as? NSView)?.animator().alphaValue = 1
//                }
//            }
//        }
        
//        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: square, queue: nil) { notif in
//            if initiallyChangeFrame {
//                initiallyChangeFrame = false
//                
//                NSAnimationContext.runAnimationGroup { [unowned self] context in
//                    context.duration = 0.3
//                    context.timingFunction = .init(name: .linear)
//                    context.allowsImplicitAnimation = true
//                    
//                    // The view will animate to the new origin
//                    animator.frame.origin.x -= 200 * 3
//                    trailing.constant = -20
//                }
//            }
//        }
    }
    
    func animateDisappearance() {
        var origin = volumeObserverView.frame.origin
        origin.x += NSScreen.main!.frame.maxX
        
        NSAnimationContext.runAnimationGroup { [self] context in
            context.duration = 0.67
            context.timingFunction = .init(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            
            // The view will animate to the new origin
            volumeObserverView.animator().frame.origin = origin
        } completionHandler: {
            NotificationCenter.default.removeObserver(self)
            self.view.window?.close()
        }
    }
    
    deinit {
        print("Deinit called, we're good.")
        print("Yosuke Hanamura <3")
    }
}
