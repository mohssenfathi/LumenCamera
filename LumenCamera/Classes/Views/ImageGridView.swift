//
//  ImageGridView.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Photos

class ImageGridView: UIView {
    
    var maxImagesPerRow: Int = 3
    var maxImagesPerColumn: Int = 3
    var spacing: CGFloat = 12.0
    
//    var assets: [PHAsset] = [] {
//        didSet { reload() }
//    }
    
    var images: [UIImage] = [] {
        didSet { reload() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        reload()
    }
    
    func reload() {

        mainStackView?.removeFromSuperview()

        mainStackView = UIStackView(frame: bounds)
        mainStackView?.spacing = spacing
//        mainStackView?.distribution = .fillEqually

        guard let mainStackView = mainStackView else { return }

        addSubview(mainStackView)
        mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: spacing).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: spacing).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: spacing).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: spacing).isActive = true

//        var imgs = images

//        while imgs.count > 0 {
//
//            let newStack = UIStackView()
//            newStack.spacing = spacing
//            newStack.distribution = .fillEqually
//            newStack.axis = random(min: 0, max: 1) == 1 ? .vertical : .horizontal
//            mainStackView.addArrangedSubview(newStack)
//
//            let num = min(random(min: 1, max: maxImagesPerRow), imgs.count)
//            for i in 0 ..< num {
//                let imageView = buildImageView(with: imgs[i])
//                newStack.addArrangedSubview(imageView)
//            }
//
//            imgs = Array(imgs[num ..< imgs.count])
//        }
    }
    
    func buildImageView(with image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
//        asset.image(size: CGSize(width: 200, height: 200), deliveryMode: .opportunistic, synchronous: false, progress: nil) { image, _ in
//            imageView.image = image
//        }
        return imageView
    }
    
    private func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }

    private var mainStackView: UIStackView?
    
}
