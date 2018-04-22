//
//  PhotoCell.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/24/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.lumenMint.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 5.0 : 0.0
        }
    }
}
