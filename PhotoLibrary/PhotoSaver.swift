//
//  LumenAlbum.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 6/26/16.
//  Copyright © 2016 mohssenfathi. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbum {

    let albumName: String
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    var assetCollection: PHAssetCollection?
    
    init(albumName: String) {
        self.albumName = albumName
        self.assetCollection = getAssetCollection() // If it already exists
    }
    
    func saveAsset(_ asset: PHAsset, completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        
        func save(to assetCollection: PHAssetCollection) {
            PHPhotoLibrary.shared().performChanges({
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                albumChangeRequest?.addAssets([asset] as NSFastEnumeration)
            }) { success, error in
                completion?(success, error)
            }
        }
        
        if let assetCollection = assetCollection {
            save(to: assetCollection)
        } else {
            createAssetCollection { (assetCollection, error) in
                guard let assetCollection = assetCollection else {
                    completion?(false, error)
                    return
                }
                save(to: assetCollection)
            }
        }
        
    }
    
    func savePhoto(_ photo: UIImage, completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        
        func save(to assetCollection: PHAssetCollection) {
            PHPhotoLibrary.shared().performChanges({
                
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                albumChangeRequest?.addAssets([assetPlaceholder!] as NSFastEnumeration)
                
            }) { success, error in
                completion?(success, error)
            }
        }
        
        if let assetCollection = assetCollection {
            save(to: assetCollection)
        } else {
            createAssetCollection { (assetCollection, error) in
                guard let assetCollection = assetCollection else {
                    completion?(false, error)
                    return
                }
                save(to: assetCollection)
            }
        }
        
    }
    

    // Fetches asset collection if it already exists
    private func getAssetCollection() -> PHAssetCollection? {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collections.firstObject {
            return collections.firstObject! as PHAssetCollection
        }
        
        return nil
    }
    
    
    private func createAssetCollection(completion: ((_ album: PHAssetCollection?, _ error: PhotoAlbumError?) -> ())?) {
        
        // If collection already exists, return it
        guard assetCollection == nil else {
            completion?(self.assetCollection, nil)
            return
        }

        
        // Otherwise, create it
        PHPhotoLibrary.shared().performChanges({
            
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            self.assetCollectionPlaceholder = request.placeholderForCreatedAssetCollection
            
        }) { success, error in
            
            print(error ?? "")
            
            if success {
                let fetchResult = PHAssetCollection.fetchAssetCollections(
                    withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier],
                    options: nil
                )
                
                self.assetCollection = fetchResult.firstObject
                completion?(self.assetCollection, nil)
            }
            else {
                print("Error creating Lumen album")
            }
        }
        
    }
    
    enum PhotoAlbumError: Error {
        case invalidName
        case noAssetCollection
    }
}


extension PhotoAlbum {
    
    func saveLivePhoto(movieURL: URL, imageURL: URL, _ completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: movieURL, options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: imageURL, options: options)
            
        }, completionHandler: { (success, error) -> Void in
            completion?(success, error)
        })
        
    }
    
}
