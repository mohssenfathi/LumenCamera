//
//  ThemeManager.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/20/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

enum Theme: String {
    case light
    case dark
    
    var title: String { return rawValue.capitalized }
}

class ThemeManager {

    var theme: Theme = .light
    
    static let shared = ThemeManager()
}

