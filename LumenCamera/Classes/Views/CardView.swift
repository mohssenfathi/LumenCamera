//
//  CardView.swift
//  Lumen
//
//  Created by Mohssen Fathi on 11/19/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var titleBackgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        titleBackgroundView.layer.masksToBounds = true
        titleBackgroundView.layer.cornerRadius = titleBackgroundView.bounds.height/2.0
        photoButton.tintColor = UIColor.lumenGrey(1.0)
        titleLabel.textColor = UIColor.lumenGrey(1.0)
        tintView.backgroundColor = UIColor.lumenGrey(0).withAlphaComponent(0.1)
        titleBackgroundView.backgroundColor = UIColor.lumenGrey(0).withAlphaComponent(0.85)
    }
}
