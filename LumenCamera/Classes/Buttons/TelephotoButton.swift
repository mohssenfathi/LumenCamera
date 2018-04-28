//
//  TelephotoButton.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 4/22/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class TelephotoButton: PMButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lumenGrey(1).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = layer.bounds.width/2.0
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            }
        }
    }
}
