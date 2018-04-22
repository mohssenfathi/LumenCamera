//
//  SnappableView.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/13/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Tools

class SnappableView: UIView {
    
    var snapInsets: UIEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12) {
        didSet { snap() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: sender.view)
        
        if sender.state == .ended {
            snap()
        } else {
            
            var newFrame = self.frame
            newFrame.origin = newFrame.origin + translation
            
            // Check to see if dragging out of bounds
            if let superview = superview {
                if newFrame.origin.x < snapInsets.left { newFrame.origin.x = snapInsets.left }
                if newFrame.origin.y < snapInsets.top  { newFrame.origin.y = snapInsets.top }
                if newFrame.maxX > superview.bounds.width - snapInsets.right {
                    newFrame.origin.x = superview.bounds.width - newFrame.width - snapInsets.right
                }
                if newFrame.maxY > superview.bounds.height - snapInsets.bottom {
                    newFrame.origin.y = superview.bounds.height - newFrame.height - snapInsets.bottom
                }
            }

            self.frame = newFrame
        }
        
        sender.setTranslation(.zero, in: sender.view)
    }
    
    func snap() {
        
        guard let superview = superview else { return }
        
        let center = self.center
        var newOrigin = CGPoint(x: snapInsets.left, y: snapInsets.top)
        
        if center.x < superview.bounds.width/2.0 {
            // Snap to left
            
            if center.y < superview.bounds.height/2.0 {
                // Snap to top
                // No-op
            }
            else {
                // Snap to bottom
                newOrigin.y = superview.bounds.height - bounds.height - snapInsets.bottom
            }
        }
        else {
            // Snap to right
            
            newOrigin.x = superview.bounds.width - bounds.width - snapInsets.right
            
            if center.y < superview.bounds.height/2.0 {
                // Snap to top
                // No-op
            }
            else {
                // Snap to bottom
                newOrigin.y = superview.bounds.height - bounds.height - snapInsets.bottom
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState], animations: {
            self.frame = CGRect(origin: newOrigin, size: self.bounds.size)
        }) { _ in
            
        }
    }
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
}


