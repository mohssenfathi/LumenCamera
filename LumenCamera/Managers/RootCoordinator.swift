//
//  RootCoordinator.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/10/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class RootCoordinator {

    enum Page: Int {
        case library
        case camera
        // case feed
    }
    
    static let shared = RootCoordinator()
    
    var viewControllers: [UIViewController] = []
    var root: RootViewController?
    
    func initialize(root: RootViewController, pages: [UIViewController]) {
        self.root = root
        self.viewControllers = pages
    }
    
    @discardableResult
    func scroll(to page: Page, animated: Bool = true) -> Bool {
        return scroll(to: page.rawValue, animated: animated)
    }
    
    @discardableResult
    private func scroll(to index: Int, animated: Bool = true) -> Bool {
        
        guard let collectionView = root?.collectionView, viewControllers.count > index else {
            return false
        }
        
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        return true
    }
}
