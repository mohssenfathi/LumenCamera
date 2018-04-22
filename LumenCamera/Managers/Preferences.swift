//
//  Preferences.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/14/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import Foundation
import AVFoundation

enum Preference: String {
    
    case captureFormat
    case showPanSliderHint
    
    static let all: [Preference] = [
        .captureFormat,
        .showPanSliderHint
    ]
    
    func getValue<T>() -> T? {
        return UserDefaults.standard.value(forKey: rawValue) as? T
    }
    
    func update(to value: Bool) {
        UserDefaults.standard.set(value, forKey: rawValue)
        Preference.synchrinize()
    }
    
    func update(to value: String) {
        UserDefaults.standard.set(value, forKey: rawValue)
        Preference.synchrinize()
    }
    
    func update(to value: Float) {
        UserDefaults.standard.set(value, forKey: rawValue)
        Preference.synchrinize()
    }
    
    func update(to value: Double) {
        UserDefaults.standard.set(value, forKey: rawValue)
        Preference.synchrinize()
    }
    
    func update(to value: Any) {
        UserDefaults.standard.set(value, forKey: rawValue)
        Preference.synchrinize()
    }
    
    static func synchrinize() {
        UserDefaults.standard.synchronize()
    }
}

struct Prefs {
    
    init() {
        Preference.all.forEach {
            if UserDefaults.standard.value(forKey: $0.rawValue) == nil {
                setInitialValue(for: $0)
            }
            Preference.synchrinize()
        }
    }
    
    private func setInitialValue(for preference: Preference) {
        switch preference {
        
        case .captureFormat:
            preference.update(to: CaptureFormat.jpeg)
        case .showPanSliderHint:
            preference.update(to: true)
        }
    }
    
    static let shared = Prefs()
}

enum CaptureFormat: Int {
    case jpeg
    case png
    case raw
}
