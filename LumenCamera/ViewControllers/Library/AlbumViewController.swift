//
//  AlbumViewController.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/28/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UIViewController {
    @IBOutlet var albumView: AlbumView?
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIButton!
    
    var collection: PHAssetCollection?
    var selectedAsset: PHAsset?
    
    var isEditButtonShown: Bool = false {
        didSet { editButton.isHidden = !isEditButtonShown }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = collection?.localizedTitle
        
        isEditButtonShown = false
        
        albumView?.collection = collection
        albumView?.showImageView(false, animated: false, completion: nil)
        
        albumView?.didSelectAsset = { asset in
            
            self.selectedAsset = asset
            asset.image({ image, info in
                guard let image = image else {
                    self.isEditButtonShown = false
                    self.selectedAsset = nil
                    return
                }
                
                self.isEditButtonShown = true
                self.albumView?.currentImage = image
                self.albumView?.showImageView(true, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func edit(_ sender: UIButton) {

    }
    
    @IBAction func close(_ sender: UIBarButtonItem?) {
        dismiss(animated: true, completion: nil)
    }
}
