//
//  RootViewController.swift
//  Lumen Camera
//
//  Created by Mohssen Fathi on 3/10/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class RootViewController: BaseViewController {

    @IBOutlet var collectionView: UICollectionView!
    var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        viewControllers =  [libraryNavigationController, cameraViewController]
        RootCoordinator.shared.initialize(root: self, pages: viewControllers)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
    
    fileprivate lazy var cameraViewController: CameraViewController = {
        return UIStoryboard(name: "Camera", bundle: Bundle(for: CameraViewController.classForCoder())).instantiateInitialViewController() as! CameraViewController
    }()
    
    lazy var libraryNavigationController: UINavigationController = {
        return UIStoryboard(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "Library") as! UINavigationController
    }()
    
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .bottom
    }
}

extension RootViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewControllerCell", for: indexPath) as? ViewControllerCell else {
            return UICollectionViewCell()
        }
        
        let vc = viewControllers[indexPath.item]
        
        for subview in cell.subviews { subview.removeFromSuperview() }
        
        cell.addSubview(vc.view)
        vc.view.frame = cell.bounds
        
        vc.view.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        
        if !childViewControllers.contains(vc) {
            vc.loadViewIfNeeded()
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
        }
        
        return cell
    }
}
