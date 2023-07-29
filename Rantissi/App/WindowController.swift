//
//  WindowController.swift
//  Rantissi
//
//  Created by Serena on 26/07/2023.
//  

import Cocoa

class WindowController: NSWindowController {
    enum Kind {
        case volumeChanging
    }
    
    init(kind: Kind) {
        let vc: NSViewController
        
        switch kind {
        case .volumeChanging:
            vc = VolumeChangingViewController()
        }
        
        let window = NSWindow(contentViewController: vc)
        super.init(window: window)
        
        switch kind {
        case .volumeChanging:
            window.styleMask.remove(.titled)
            window.backgroundColor = .clear
            window.level = .init(Int(CGWindowLevelForKey(.maximumWindow)))
            
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.setFrame(NSScreen.main!.visibleFrame, display: true, animate: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
