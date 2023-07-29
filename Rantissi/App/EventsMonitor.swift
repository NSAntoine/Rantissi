//
//  EventsMonitor.swift
//  Rantissi
//
//  Created by Serena on 26/07/2023.
//  

import Cocoa

@objc
class EventsMonitor: NSObject {
    static let shared = EventsMonitor()
    
    private var _currentVC: VolumeChangingViewController? = nil
    
    // In order to stop scrolling in other apps while the user is changing their volume,
    // We use CoreGraphics event taps in order to intercept those events,
    // block them from other apps, and then change volume as we see fit
    private var _currentScrollTap: CFMachPort? = nil
    
    // The observer for otherMouseDown, leftMouseDown, and rightMouseDown.
    private var _mouseDownTap: CFMachPort? = nil
    
    var isIncreasingOrDecreasing: Bool = false {
        didSet {
            if isIncreasingOrDecreasing {
                setScrollerListener()
            } else {
                stopScrollTap()
            }
        }
    }
    
    var soundInterval: Float = Preferences.soundInterval
    
    private override init() {}
    
    @objc
    func openAccessibilityControl() {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: NSDictionary = [prompt: true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    func start() {
        if !AXIsProcessTrusted() {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Rantissi needs access to Accessibility Control."
            alert.informativeText = "In order to monitor scrolling & block it from other apps, restart the app once you've given it permissions"
            
            alert.addButton(withTitle: "Cancel")
            
            let button = alert.addButton(withTitle: "Open Settings")
            
            button.target = self
            button.action = #selector(openAccessibilityControl)
            
            alert.runModal()
        }
        
        
        guard _mouseDownTap == nil else { return }
        
        // Mask for all (...)mouseDown events
        let mouseDownMask =
        (1 << CGEventType.otherMouseDown.rawValue) |
        (1 << CGEventType.leftMouseDown.rawValue)  |
        (1 << CGEventType.rightMouseDown.rawValue)
        
        let tap = CGEvent.tapCreate(tap: .cghidEventTap,
                                    place: .headInsertEventTap,
                                    options: .defaultTap,
                                    eventsOfInterest: CGEventMask(mouseDownMask),
                                    callback: { proxy, type, event, context in
            let monitor = Unmanaged<EventsMonitor>.fromOpaque(context!).takeUnretainedValue()
            
            switch type {
                
            case .leftMouseDown, .rightMouseDown:
                if monitor.isIncreasingOrDecreasing {
                    monitor._currentVC?.animateDisappearance()
                    monitor._currentVC = nil
                    monitor.isIncreasingOrDecreasing = false
                    return nil // Dismissing the _currentVC, don't give anyone else the event
                }
                /*
                 Trackpad support:
                else if event.getIntegerValueField(.mouseEventSubtype) == 3, /* Trackpad == 3 */
                        event.getIntegerValueField(.mouseEventClickState) == 3 /* triple tap for trackpads */ {
                    
                    let controller = WindowController(kind: .volumeChanging)
                    monitor._currentVC = controller.contentViewController as? VolumeChangingViewController
                    controller.showWindow(nil)
                    
                    monitor.isIncreasingOrDecreasing = true
                    return nil // Don't register it elsewhere
                }
                 */
                
            case .otherMouseDown:
                if monitor.isIncreasingOrDecreasing {
                    monitor._currentVC?.animateDisappearance()
                    monitor._currentVC = nil
                    monitor.isIncreasingOrDecreasing = false
                    return nil
                } else {
                    let controller = WindowController(kind: .volumeChanging)
                    monitor._currentVC = controller.contentViewController as? VolumeChangingViewController
                    controller.showWindow(nil)
                    
                    monitor.isIncreasingOrDecreasing = true
                }
            default:
                break
            }
            
            return Unmanaged.passUnretained(event)
        }, userInfo: Unmanaged.passUnretained(self).toOpaque())
        
        guard let tap else { return }
        
        addTap(tap)
        self._mouseDownTap = tap
    }
    
    func setScrollerListener() {
        guard _currentScrollTap == nil else { return }
        
        let tap = CGEvent.tapCreate(tap: .cghidEventTap,
                                    place: .headInsertEventTap,
                                    options: .init(rawValue: 0)!,
                                    eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
                                    callback: { proxy, type, event, ctx in
            let obj = Unmanaged<EventsMonitor>.fromOpaque(ctx!).takeUnretainedValue()
            obj.setVolume(accordingTo: event)
            
            return nil
        }, userInfo: Unmanaged.passUnretained(self).toOpaque())!
        
        addTap(tap)
        self._currentScrollTap = tap
        
    }
    
    func addTap(_ tap: CFMachPort) {
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }
    
    /*
     Dead commented code ahead:
     Due to the (potential, unchecked) overhead of creating an NSEvent
     FOR EVERY SINGLE scroll event
     i've decided instead to just use CGEvent directly
     see `setVolume(accordingTo:)`
     
    func setVolume(accordingToEvent event: NSEvent) {
        let scrolledDown = event.scrollingDeltaY < 0
        self.setVolume(scrolledDown: scrolledDown, interval: event. ? self.soundInterval / 6 : self.soundInterval)
    }hasPreciseScrollingDeltas
     */
    
    func setVolume(accordingTo cgEvent: CGEvent) {
        let scrolledDown = cgEvent.getDoubleValueField(.scrollWheelEventPointDeltaAxis1) < 0
        // For scrolling events, we can find out if it's a trackpad by checking if scrollWheelEventIsContinuous == 1
        let isTrackpad = cgEvent.getDoubleValueField(.scrollWheelEventIsContinuous) == 1.0
        
        self.setVolume(scrolledDown: scrolledDown,
                       interval: isTrackpad ? self.soundInterval / 10 : self.soundInterval)
    }
    
    func setVolume(scrolledDown: Bool, interval soundInterval: Float) {
        do {
            let current = try Sound.shared.readVolume()
            
            let _newVolumeToSet = scrolledDown ? current + soundInterval : current - soundInterval
            // make sure it's not lower than 0, and that it's not greater than 1
            let newVolumeToSet = min(max(0, _newVolumeToSet), 1)
            
            try Sound.shared.setVolume(newVolumeToSet)
            self._currentVC?.volumeObserverView.setVolume(newVolumeToSet)
        } catch {
            print("Error? how lol")
        }
    }
    
    func stopScrollTap() {
        if let _currentScrollTap {
            CGEvent.tapEnable(tap: _currentScrollTap, enable: false)
            self._currentScrollTap = nil
        }
    }
    
    func stopTap(keyPath: ReferenceWritableKeyPath<EventsMonitor, CFMachPort?>) {
        if let val = self[keyPath: keyPath] {
            CGEvent.tapEnable(tap: val, enable: false)
            self[keyPath: keyPath] = nil
        }
    }
    
    func stop() {
//        if let _mouseDownListener {
//            NSEvent.removeMonitor(_mouseDownListener)
//            self._mouseDownListener = nil
//        }
        
        stopTap(keyPath: \._currentScrollTap)
        stopTap(keyPath: \._mouseDownTap)
//        
//        if let _mouseDownTap {
//            CGEvent.tapEnable(tap: _mouseDownTap, enable: false)
//            self._mouseDownTap = nil
//        }
//        
//        stopScrollTap()
    }
}
