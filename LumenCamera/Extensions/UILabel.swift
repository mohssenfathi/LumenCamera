//
//  UILabel.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/26/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

extension UILabel {
    
    @IBInspectable
    var lumenGreyTextColor: CGFloat {
        get {
            return 0  // Do this later
        }
        set {
            textColor = UIColor.lumenGrey(newValue)
        }
    }
}
