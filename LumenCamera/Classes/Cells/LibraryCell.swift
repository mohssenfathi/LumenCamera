//
//  LibraryCell.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/3/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import PhotoLibrary
import Photos
import Tools

class LibraryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var collection: PHAssetCollection? {
        didSet {
            assets = collection?.assets ?? []
            titleLabel.text = collection?.localizedTitle?.uppercased()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        containerView.backgroundColor = UIColor.lumenGrey(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10.0
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.25
        layer.shadowPath = UIBezierPath(roundedRect: containerView.frame, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        layer.shadowRadius = 8.0
    }
    
    var assets: [PHAsset] = []
}
