//
//  VolumeObserverView.swift
//  Rantissi
//
//  Created by Serena on 27/07/2023.
//  

import Cocoa

class VolumeObserverView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setupUI()
    }
    
    let slider = NSSlider()
    let valueLabel = NSTextField(labelWithString: String(format: "%.2f", try! Sound.shared.readVolume() * 100))
    
    func setVolume(_ vol: Float) {
        slider.floatValue = vol
        valueLabel.stringValue = String(format: "%.2f", vol * 100)
    }
    
    func setupUI() {
        
        let layer = CALayer()
        layer.backgroundColor = NSColor(red: 0.19, green: 0.19, blue: 0.19, alpha: 1).cgColor
        layer.cornerRadius = 10
        self.layer = layer
        
        let visualEffect = NSVisualEffectView()
        visualEffect.material = .sidebar
        visualEffect.state = .active
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffect)
        
        NSLayoutConstraint.activate([
            visualEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffect.topAnchor.constraint(equalTo: topAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        let current = try! Sound.shared.readVolume()
        
        slider.minValue = 0
        slider.maxValue = 1
        slider.target = self
        slider.action = #selector(sliderDidChange)
        slider.floatValue = current
        
        let font = NSFont.boldSystemFont(ofSize: 10)
        
        let explanationLabel = NSTextField(wrappingLabelWithString: "Change the volume by scrolling, and click anywhere on screen to stop.")
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.font = font
        explanationLabel.textColor = .secondaryLabelColor
        explanationLabel.maximumNumberOfLines = 0
        addSubview(explanationLabel)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = font
        valueLabel.textColor = .secondaryLabelColor
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            explanationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            explanationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            explanationLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            valueLabel.centerYAnchor.constraint(equalTo: explanationLabel.bottomAnchor, constant: 14),
            
            slider.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            slider.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 5)
        ])
    }
    
    @objc
    func sliderDidChange(sender: NSSlider) {
        try! Sound.shared.setVolume(sender.floatValue)
        valueLabel.stringValue = String(format: "%.2f", sender.floatValue * 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
