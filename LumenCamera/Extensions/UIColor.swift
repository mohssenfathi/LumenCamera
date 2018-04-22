//
//  UIColor.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/20/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit
import Tools

extension UIColor {
    
    static var lumenMint: UIColor {
        switch ThemeManager.shared.theme {
        case .light:    return UIColor(hex: 0x50E3C2)
        case .dark:     return UIColor(hex: 0x24D9B0)
        }
    }
    
    static var lumenButtonSelected: UIColor {
        switch ThemeManager.shared.theme {
        case .light:    return UIColor(hex: 0x9EECDA)
        case .dark:     return UIColor(hex: 0x95CEC3)
        }
    }
    
    static func lumenGrey(_ i: CGFloat) -> UIColor {
        
        var i = i
        Tools.clamp(&i, low: 0.0, high: 1.0)
        
        switch ThemeManager.shared.theme {
        case .light:    i = 1.0 - i
        case .dark:     break
        }
        
        return UIColor(white: i, alpha: 1.0)
    }
    
    static var lumenGold = UIColor(hex: 0xF0D521)
    static var histogramRed = UIColor.red
    static var histogramGreen = UIColor.green
    static var histogramBlue = UIColor.blue
    static var histogramAlpha = UIColor.white
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}
