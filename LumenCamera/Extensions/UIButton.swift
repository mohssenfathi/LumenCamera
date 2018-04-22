//
//  UIButton.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/26/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

@IBDesignable
extension UIButton {
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = borderColor?.cgColor }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.masksToBounds = cornerRadius > 0
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var lumenGreyColor: CGFloat {
        get {
            return 0  // Do this later
        }
        set {
            if buttonType == .system {
                tintColor = UIColor.lumenGrey(newValue)
            }
            else if buttonType == .custom {
                titleLabel?.textColor = UIColor.lumenGrey(newValue)
                // Set image tint?
            }
        }
    }
}


@IBDesignable
extension UIBarButtonItem {
    
    @IBInspectable
    var lumenGreyColor: CGFloat {
        get {
            return 0  // Do this later
        }
        set {
            tintColor = UIColor.lumenGrey(newValue)
        }
    }
}
