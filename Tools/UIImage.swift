//
//  UIImage.swift
//  Tools
//
//  Created by Mohssen Fathi on 11/22/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import Foundation

public
extension UIImage {
    
    public func scaled(to scale: CGFloat) -> UIImage? {
        return scaled(to: size * scale)
    }
    
    public func scaled(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func flipped(vertically: Bool, horizontally: Bool) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        guard let cgImage = cgImage, let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        if vertically {
            // Do nothing
        }
        else if horizontally {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
            
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        }
        else {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        let flipped = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        return flipped
    }
}
