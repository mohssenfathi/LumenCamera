//
//  UIView.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/25/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    var lumenGreyBackground: CGFloat {
        get {
            return 0 // Do this later
        }
        set {
            backgroundColor = UIColor.lumenGrey(newValue)
        }
    }
    
    func addBackgroundGradient(from: CGFloat, to: CGFloat) {
        
        for gradient in (layer.sublayers ?? []).filter({ $0 is CAGradientLayer }) {
            gradient.removeFromSuperlayer()
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.lumenGrey(to).cgColor, UIColor.lumenGrey(from).cgColor]
        gradient.startPoint = CGPoint(x: 0.4, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.6, y: 0.0)
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    func addShadow() {
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lumenGrey(1.0).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        let radius: CGFloat = layer.cornerRadius
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        layer.shadowRadius = 15.0
    }
    
    //    func snapshot() -> UIImage? {
    //        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    //        drawHierarchy(in: bounds, afterScreenUpdates: false)
    //        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
    //        UIGraphicsEndImageContext()
    //        return snapshotImage
    //    }
    //
    //    func snapshotView() -> UIView? {
    //        if let snapshotImage = snapshot() {
    //            return UIImageView(image: snapshotImage)
    //        } else {
    //            return nil
    //        }
    //    }
}
