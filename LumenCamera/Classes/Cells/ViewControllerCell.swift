//
//  ViewControllerCell.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

class ViewControllerCell: UICollectionViewCell {

    var viewController: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)
    }
    
    func add(viewController: UIViewController, parent: UIViewController, inset: CGFloat = 0.0) {
        
        self.viewController = viewController
        
        for subview in contentView.subviews { subview.removeFromSuperview() }
        
        contentView.addSubview(viewController.view)
        viewController.view.frame = bounds
        
        viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        
        if !parent.childViewControllers.contains(viewController) {
            viewController.loadViewIfNeeded()
//            _ = viewController.view
            parent.addChildViewController(viewController)
            viewController.didMove(toParentViewController: parent)
        }
        
    }
    
}
