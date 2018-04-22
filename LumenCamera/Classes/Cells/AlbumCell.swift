//
//  AlbumCell.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/24/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit


class AlbumViewCell: UICollectionViewCell {
    @IBOutlet var albumView: AlbumView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet var containerShadowView: UIView!
    @IBOutlet var containerView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10.0
        
        containerShadowView.layer.masksToBounds = false
        containerShadowView.layer.shadowColor = UIColor.lumenGrey(1.0).cgColor
        containerShadowView.layer.shadowOffset = .zero
        containerShadowView.layer.shadowOpacity = 0.2
        containerShadowView.layer.shadowPath = UIBezierPath(
            roundedRect: containerShadowView.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 10, height: 10)
            ).cgPath
        containerShadowView.layer.shadowRadius = 15.0
    }
    
    override var isHighlighted: Bool {
        didSet {
            setState(tapped: isHighlighted)
        }
    }
    
    func setState(tapped: Bool, completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.7,
                       options: [.allowUserInteraction], animations: {
                        let scale: CGFloat = tapped ? 0.95 : 1.0
                        self.containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        self.containerShadowView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            completion?()
        })
    }
}
