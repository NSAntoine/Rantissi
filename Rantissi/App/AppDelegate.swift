//
//  AppDelegate.swift
//  Rantissi
//
//  Created by Serena on 26/07/2023.
//  

import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static func main() {
        let del = AppDelegate()
        NSApplication.shared.delegate = del
        NSApplication.shared.run()
    }
    
//    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var statusItem: NSStatusItem!
    
    let soundIntervalValueLabel = NSTextField(labelWithString: String(format: "%.2f", Preferences.soundInterval * 100))
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "cursorarrow.click.2")
        
        let menu = NSMenu()

        
        let titleItem = NSMenuItem()
        titleItem.view = makeRantissiTitleView()
        
        menu.addItem(titleItem)
        menu.addItem(.separator())
        
        let sliderItem = NSMenuItem()
        sliderItem.view = makeSliderView()
        menu.addItem(sliderItem)
        
        menu.addItem(.separator())
        menu.addItem(withTitle: "Source Code", action: #selector(openSourceCode), keyEquivalent: "")
        
        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = .command
        menu.addItem(quit)
        
        statusItem.menu = menu
        
        if Preferences.isAppEnabled {
            EventsMonitor.shared.start()
        }
    }
    
    @objc
    func openSourceCode() {
        NSWorkspace.shared.open(URL(string: "https://github.com/SerenaKit/Rantissi")!)
    }
    
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func makeSliderView() -> NSView {
        let view = NSView(frame: CGRect(origin: .zero, size: CGSize(width: 230, height: 98)))
        
        let slider = NSSlider(value: Double(Preferences.soundInterval), minValue: 0, maxValue: 1, target: self, action: #selector(sliderChanged(sender:)))
        slider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider)
        
        let topLabel = NSTextField(labelWithString: "Sound Interval")
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.font = .boldSystemFont(ofSize: 11.5)
        
        let bottomLabel = NSTextField(
            wrappingLabelWithString: "The % of sound that gets added or reduced when scrolling, default is 6.25, same as System Volume up/down buttons"
        )
        
        bottomLabel.textColor = .secondaryLabelColor
        bottomLabel.font = .systemFont(ofSize: 10)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        soundIntervalValueLabel.translatesAutoresizingMaskIntoConstraints = false
        soundIntervalValueLabel.textColor = .secondaryLabelColor
        soundIntervalValueLabel.font = .systemFont(ofSize: 10)
        
        view.addSubview(topLabel)
        view.addSubview(bottomLabel)
        view.addSubview(soundIntervalValueLabel)
        
        
        NSLayoutConstraint.activate([
            topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            
            bottomLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 3),
            bottomLabel.leadingAnchor.constraint(equalTo: topLabel.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            soundIntervalValueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            soundIntervalValueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            soundIntervalValueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: soundIntervalValueLabel.trailingAnchor, constant: 5),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        
        return view
    }
    
    
    @objc
    func sliderChanged(sender: NSSlider) {
        Preferences.soundInterval = sender.floatValue
        soundIntervalValueLabel.stringValue = String(format: "%.2f", sender.floatValue * 100)
    }
    
    func makeRantissiTitleView() -> NSView {
        let size: CGSize
        
        // on OS X 10.15+, we use NSSwitch instead of a checkbox NSButton, which takes up more space
        if #available(macOS 10.15, *) {
            size = CGSize(width: 230, height: 27)
        } else {
            size = CGSize(width: 230, height: 19)
        }
        
        let view = NSView(frame: CGRect(origin: .zero, size: size))
        let label = NSTextField(labelWithString: "Rantissi")
        
        if #available(macOS 11, *) {
            label.font = .preferredFont(forTextStyle: .headline)
        } else {
            label.font = .boldSystemFont(ofSize: 13)
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        
        let toggle: NSView
        
        if #available(macOS 10.15, *) {
            let switchControl = NSSwitch()
            switchControl.action = #selector(switchControlTapped(sender:))
            switchControl.target = self
            switchControl.state = Preferences.isAppEnabled ? .on : .off
            toggle = switchControl
        } else {
            let button = NSButton(checkboxWithTitle: "", target: self, action: #selector(enableButtonTapped(sender:)))
            button.state = Preferences.isAppEnabled ? .on : .off
            toggle = button
        }
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggle)
        
        NSLayoutConstraint.activate([
            toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            toggle.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
        ])
        
        if #available(macOS 10.15, *) {
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: toggle.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        return view
    }
    
    @objc
    func enableButtonTapped(sender: NSButton) {
        Preferences.isAppEnabled = (sender.state == .on)
    }
    
    @objc
    @available(macOS 10.15, *)
    func switchControlTapped(sender: NSSwitch) {
        Preferences.isAppEnabled = (sender.state == .on)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
