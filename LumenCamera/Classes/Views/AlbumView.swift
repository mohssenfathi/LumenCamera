//
//  AlbumView.swift
//  Lumen
//
//  Created by Mohssen Fathi on 1/28/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import PhotoLibrary
import Tools

class AlbumView: UIView {

    @IBOutlet var livePhotoContainerView: UIView!
    @IBOutlet var livePhotoView: PHLivePhotoView!
    @IBOutlet var livePhotoIcon: UIButton!
    @IBOutlet var forceTouchButton: ForceTouchButton!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewContainer: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    var imageViewContentMode: UIViewContentMode = .scaleAspectFill {
        didSet { updateContentModes() }
    }
    
    var currentImage: UIImage? {
        didSet { imageView.image = currentImage }
    }
    
    var imageViewHeight: CGFloat {
        get { return imageViewHeightConstraint.constant }
        set { imageViewHeightConstraint.constant = newValue }
    }

    var imageSize: CGSize = CGSize(width: 200, height: 200)
    var didSelectAsset: ((PHAsset) -> ())?
    var cellsPerRow: Int = 3
    var assets: [PHAsset] = []
    
    var collection: PHAssetCollection? {
        didSet { reload() }
    }

    
    func reload() {
        assets.removeAll()
        cacheIndex = 0
        
        updateContentModes()
        
        livePhotoIcon.tintColor = UIColor.lumenGold
        
//        collectionViewContainer.addShadow()
        addBackgroundGradient(from: 0.0, to: 0.1)
        
        forceTouchButton.addTarget(self, action: #selector(self.forceTouchButtonValueChanged(_:)), for: .valueChanged)
        
        if let asset = collection?.fetchAssets(max: 1).first {
            updateImageView(with: asset)
        }
        
        if cacheIndex == 0 {
            activityIndicator?.startAnimating()
        }
        
        DispatchQueue.global(qos: .background).async {
            self.assets = self.collection?.assets ?? []
            self.cacheNextBatch()
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                }, completion: nil)
                
            }
        }
    }
    
    @objc func forceTouchButtonValueChanged(_ sender: ForceTouchButton) {
        sender.force > sender.maximumForce/2.0 ? livePhotoView.startPlayback(with: .full) : livePhotoView.stopPlayback()
    }
    
    func cacheNextBatch() {
        
        let mi = min(assets.count, cacheIndex + cacheIncrement)
        PhotoLibrary.startCaching(assets: Array(assets[cacheIndex ..< mi]), size: imageSize, contentMode: .aspectFill)
        cacheIndex += cacheIncrement
    }
    
    func updateImageView(with asset: PHAsset, completion: (() -> ())? = nil) {
        
        if asset.isLivePhoto {

            imageView.isHidden = true
            livePhotoContainerView.isHidden = false

            asset.livePhoto { [weak self] livePhoto, info in
                self?.livePhotoView.livePhoto = livePhoto
                self?.livePhotoView.startPlayback(with: .hint)
            }
        }
        else {
            
            imageView.isHidden = false
            livePhotoContainerView.isHidden = true
            
            asset.image(
                size: imageView.bounds.size * UIScreen.main.scale,
                deliveryMode: .highQualityFormat,
                synchronous: false,
                progress: nil, { image, info in
                    self.imageView.image = image
            })
        }
    }
    
    func showImageView(_ show: Bool, animated: Bool = true, completion: (() -> ())? = nil) {
        let value = show ? bounds.height * 0.4 : 0.0
        animateConstraint(imageViewHeightConstraint, to: value, animated: animated, completion: completion)
    }
    
    private func updateContentModes() {
        if imageView != nil { imageView.contentMode = imageViewContentMode }
        if livePhotoView != nil { livePhotoView.contentMode = imageViewContentMode }
        
    }
    
    fileprivate var cacheIndex: Int = 0
    fileprivate var cacheIncrement: Int = 100
}

// MARK: - UICollectionView

/// DataSource
extension AlbumView: UICollectionViewDataSource {
    
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
extension AlbumView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        updateImageView(with: asset)
        didSelectAsset?(asset)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        updateCellMask(cell, at: indexPath)
        
        if indexPath.item > cacheIndex {
            cacheNextBatch()
        }
    }
    
    func updateCellMask(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
     
        cell.layer.cornerRadius = 20.0
        
        func defaultMask() {
            cell.layer.maskedCorners = CACornerMask(rawValue: 0)
            cell.layer.cornerRadius = 0.0
        }
        
        switch indexPath.item {
        case 0:
            cell.layer.maskedCorners = .layerMinXMinYCorner
        case cellsPerRow - 1:
            cell.layer.maskedCorners = .layerMaxXMinYCorner
        case assets.count - 1:
            if indexPath.item % cellsPerRow == cellsPerRow - 1 {
                cell.layer.maskedCorners = .layerMaxXMaxYCorner
            } else {
                defaultMask()
            }
        case assets.count - cellsPerRow + 1:
            if indexPath.item % cellsPerRow == 0 {
                cell.layer.maskedCorners = .layerMinXMaxYCorner
            } else {
                defaultMask()
            }
        default:
            defaultMask()
        }
    
    }
}

/// Layout
extension AlbumView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.width / CGFloat(cellsPerRow)
        return CGSize(width: side, height: side)
    }
    
}

