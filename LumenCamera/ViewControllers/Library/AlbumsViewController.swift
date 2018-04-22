//
//  AlbumsViewController.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit
import Photos
import PhotoLibrary
import Tools

class AlbumsViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraButtonContainer: UIView!
    @IBOutlet weak var cameraButtonTopConstraint: NSLayoutConstraint!
    
    var dataSource = AlbumsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        dataSource.parent = self
        dataSource.imageSize = CGSize(width: collectionView.bounds.width - 20.0, height: 300.0) * UIScreen.main.scale
        collectionView.dataSource = dataSource
        
        cameraButtonContainer.layer.masksToBounds = true
        cameraButtonContainer.layer.cornerRadius = cameraButtonContainer.bounds.height/2.0
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        RootCoordinator.shared.scroll(to: .camera, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "album" {
            
            guard let cell = sender as? AlbumViewCell,
                let indexPath = collectionView.indexPath(for: cell) else { return }
        
            selectedCell = cell
            
            let albumViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? AlbumViewController
//            let albumViewController = segue.destination as? AlbumViewController
            albumViewController?.collection = dataSource.sections[indexPath.section].albums[indexPath.item].collection
        }
    }

    fileprivate func inset(for assetSize: CGSize) -> UIEdgeInsets {
        if assetSize.width < assetSize.height {
            return UIEdgeInsetsMake(0, -35, 0, -35)
        } else {
            let inset = ((assetSize.width / assetSize.height) - 1.0) * -300.0
            return UIEdgeInsetsMake(0, inset, 0, inset)
        }
    }
    
    var selectedCell: AlbumViewCell?
}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20.0, height: 300.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let cell = cell as? AlbumCell else { return }
        
//        if collectionView.collectionViewLayout is UICollectionViewPagingFlowLayout,
//            let asset = dataSource.albums[indexPath.item].assets.first {
//            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
//            cell.imageViewInsets = inset(for: size)
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let limit: CGFloat = 50.0
        var offset = scrollView.contentOffset.y

        if offset < 0.0 {
            cameraButtonTopConstraint.constant = 35.0 - offset
        } else {
            Tools.clamp(&offset, low: 0, high: limit)
            cameraButtonTopConstraint.constant = Tools.convert(offset, oldMin: 0, oldMax: limit, newMin: 35.0, newMax: 15.0)
        }
        
//        for cell in collectionView.visibleCells {
//            guard let cell = cell as? AlbumCell else { continue }
//
//            if collectionView.collectionViewLayout is UICollectionViewPagingFlowLayout {
//                if let imageSize = cell.cardView.imageView.image?.size {
//                    let rect = view.convert(cell.frame, from: cell.superview)
//                    let offset = (rect.midX - collectionView.bounds.width/2.0)/collectionView.bounds.width
//                    let dx = inset(for: imageSize).left * -offset
//                    cell.cardView.imageView.transform = CGAffineTransform(translationX: dx, y: 0)
//                }
//            }
//            else {
//                cell.cardView.imageView.transform = .identity
//            }
//        }
    }
}


class AlbumsDataSource: NSObject, UICollectionViewDataSource {

    struct AlbumSection {
        var title: String
        var albums: [Album]
    }

    struct Album {
        var collection: PHAssetCollection
        var keyAsset: PHAsset?
    }
    
    var sections = [AlbumSection]()
    var albums = [Album]()
    var collections = [PHAssetCollection]()
    var parent: UIViewController?
    
    var imageSize = CGSize(width: 500, height: 500)
    
    override init() {
        super.init()
        loadData()
    }
    
    func loadData() {
        
        collections = PhotoLibrary.collections().filter { $0.estimatedAssetCount > 0 }
        sections.removeAll()
        
        // All Photos
        if let i = collections.enumerated().filter({ $0.element.localizedTitle?.lowercased() == "all photos" }).first {
            collections.remove(at: i.offset)
            sections.append(AlbumSection(
                title: "All Photos",
                albums: [Album(collection: i.element, keyAsset: i.element.fetchAssets(max: 1).first)]
                )
            )
        }
        
        sections.append(
            AlbumSection(
                title: "Albums",
                albums: collections.map {
                    Album(collection: $0, keyAsset: $0.fetchAssets(max: 1).first)
                }
            )
        )
        
        let assets = sections.reduce([], {
            $0 + $1.albums.map({ $0.keyAsset }).compactMap { $0 }
        })

        PhotoLibrary.startCaching(assets: assets, size: imageSize, contentMode: .aspectFill)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "AlbumsSectionTitle", for: indexPath)
        if let label = view.viewWithTag(101) as? UILabel {
            label.text = sections[indexPath.section].title
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as? AlbumViewCell else {
            return UICollectionViewCell()
        }
        
        let album = sections[indexPath.section].albums[indexPath.item]
        let collection = album.collection

        cell.titleLabel.text = collection.localizedTitle
        cell.albumView.imageViewHeight = cell.bounds.height
        cell.albumView.imageViewContentMode = .scaleAspectFill
        
        let count = collection.estimatedAssetCount
        if count == NSNotFound {
            cell.detailLabel.text = nil
        } else {
            cell.detailLabel.text = "\(collection.estimatedAssetCount) \((count > 1) ? "Photos" : "Photo")"
        }

        
        album.keyAsset?.image(size: imageSize, deliveryMode: .highQualityFormat, synchronous: false, progress: nil, { image, info in
            cell.albumView.currentImage = image
        })
        
        return cell
    }
    
}

