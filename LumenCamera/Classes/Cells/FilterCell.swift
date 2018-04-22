//
//  FilterCell.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/27/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit


// MARK: - Cells
class FilterCategoryCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    override var backgroundColor: UIColor? {
        didSet {
            defaultBackgroundColor = backgroundColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            super.backgroundColor = isSelected ? UIColor.lumenMint : defaultBackgroundColor
        }
    }
    
    private var defaultBackgroundColor: UIColor?
}


class FilterCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var image: UIImage? {
        didSet { imageView.image = image }
    }
    
    override var isHighlighted: Bool {
        didSet { imageView.alpha = isHighlighted ? 0.8 : 1.0 }
    }
    
    override var isSelected: Bool {
        didSet { showEditButton(isSelected, animated: true) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = editButton.bounds.height/2.0
        showEditButton(false, animated: false)
    }
    
    func showEditButton(_ show: Bool, animated: Bool) {
        
        let scale: CGFloat = show ? 1.0 : 0.0
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.editButton.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
        
    }
}
