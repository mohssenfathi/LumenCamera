//
//  ButtonCell.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    
    var button: UIButton!
    
    var selectedColor: UIColor = .lumenGold
    
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    var image: UIImage? {
        didSet {
            button.setImage(image, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        button = UIButton(type: .system)
        button.frame = bounds
        addSubview(button)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        button.isUserInteractionEnabled = false
        isSelected = false
    }
    
    override var isSelected: Bool {
        didSet {
            button.tintColor = isSelected ? selectedColor : UIColor.lumenGrey(1)
        }
    }
}
