//
//  Animations.swift
//  Lumen
//
//  Created by Mohssen Fathi on 2/4/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func animateConstraint(_ constraint: NSLayoutConstraint, to value: CGFloat, duration: Double = 0.3, animated: Bool = true, completion: (() -> ())? = nil) {
        view.animateConstraint(constraint, to: value, duration: duration, animated: animated, completion: completion)
    }
    
    func animate(duration: Double = 0.35, _ contents: @escaping (() -> ()), completion:(() -> ())? = nil) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState], animations: {
                contents()
            }) { _ in
                completion?()
            }
        }
    }
}

extension UIView {
    
    func animateConstraint(_ constraint: NSLayoutConstraint, to value: CGFloat, duration: Double = 0.3, animated: Bool = true, completion: (() -> ())? = nil) {
        
        constraint.constant = value
        setNeedsLayout()
        
        guard animated else {
            completion?()
            return
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
}


