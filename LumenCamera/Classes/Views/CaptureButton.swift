//
//  CaptureButton.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class CaptureButton: UIButton {
    
    var isInverted: Bool = false {
        didSet { updateButton() }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateButton()

            UIView.animate(withDuration: 0.2) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            }
        }
    }
    
    func updateButton() {
    
        var bg: CGFloat = 0.6
        var border: CGFloat = 0.8
        
        if isHighlighted {
            bg = 0.4
            border = 0.6
        }
        
        if isInverted {
            bg = 1.0 - bg
            border = 1.0 - border
        }
        
        backgroundColor = UIColor.lumenGrey(bg).withAlphaComponent(0.25)
        layer.borderColor = UIColor.lumenGrey(border).withAlphaComponent(0.8).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = bounds.width/2.0
        layer.borderWidth = 6.0
        isHighlighted = false
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        generator.prepare()
        generator.impactOccurred()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private let generator = UIImpactFeedbackGenerator(style: .light)
}


