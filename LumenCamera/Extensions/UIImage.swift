//
//  UIImage.swift
//  Lumen
//
//  Created by Mohssen Fathi on 11/12/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

extension UIImage {
    
    func tinted(with color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0.0, y: -size.height)
        context.setBlendMode(.multiply)
        
        let rect = CGRect(origin: .zero, size: size)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
}
