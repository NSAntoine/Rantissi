//
//  Preferences.swift
//  Rantissi
//
//  Created by Serena on 27/07/2023.
//  

import Foundation

@propertyWrapper
struct Storage<Value> {
    let key: String
    let defaultValue: Value
    let callback: (Value) -> Void
    
    var wrappedValue: Value {
        get {
            (UserDefaults.standard.object(forKey: key) as? Value) ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            callback(newValue)
        }
    }
}

enum Preferences {
    @Storage(key: "isEnabled", defaultValue: true, callback: { newValue in
        if newValue {
            EventsMonitor.shared.start()
        } else {
            EventsMonitor.shared.stop()
        }
    })
    static var isAppEnabled: Bool
    
    @Storage(key: "SoundSteppingInterval", defaultValue: 6.25 / 100, callback: { value in
        EventsMonitor.shared.soundInterval = value
    })
    static var soundInterval: Float
}
