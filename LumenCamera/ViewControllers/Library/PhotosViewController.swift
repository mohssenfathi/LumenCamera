//
//  PhotosViewController.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit
import Photos
import PhotoLibrary
import Tools

class PhotosViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView?

    var imageSize: CGSize = CGSize(width: 200, height: 200)
    
    var didSelectAsset: ((PHAsset) -> ())?
    
    var cellsPerRow: Int = 3
    var assets: [PHAsset] = []
    
    var collection: PHAssetCollection? {
        didSet {
            title = collection?.localizedTitle
            reload()
        }
    }
    
    func reload() {
        assets.removeAll()
        cacheIndex = 0
        
        DispatchQueue.global(qos: .background).async {
            self.assets = self.collection?.assets ?? []
            self.cacheNextBatch()
            DispatchQueue.main.async {
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                }, completion: nil)
                
            }
        }
    }
    
    func cacheNextBatch() {
        
        let mi = min(assets.count, cacheIndex + cacheIncrement)
        PhotoLibrary.startCaching(assets: Array(assets[cacheIndex ..< mi]), size: imageSize, contentMode: .aspectFill)
        cacheIndex += cacheIncrement
    }
    
    fileprivate var cacheIndex: Int = 0
    fileprivate var cacheIncrement: Int = 100
}

// MARK: - UICollectionView

/// DataSource
extension PhotosViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        assets[indexPath.item].image(size: imageSize, synchronous: false) { image, info in
            cell.imageView.image = image
        }
                
        return cell
    }
}

/// Delegate
extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectAsset?(assets[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item > cacheIndex {
            cacheNextBatch()
        }
    }
}

/// Layout
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.width / CGFloat(cellsPerRow)
        return CGSize(width: side, height: side)
    }
    
}
