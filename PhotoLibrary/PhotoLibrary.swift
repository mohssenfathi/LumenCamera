//
//  PhotoLibrary.swift
//  PhotoLibrary
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import Photos

public class PhotoLibrary {
    public static let shared = PhotoLibrary()
    
    static public func saveAsset(_ asset: PHAsset, to album: String, completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        let album = PhotoAlbum(albumName: album)
        album.saveAsset(asset, completion: completion)
    }
    
    static public func savePhoto(_ photo: UIImage, to album: String, completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        let album = PhotoAlbum(albumName: album)
        album.savePhoto(photo, completion: completion)
    }
    
    let manager = PHCachingImageManager()
}


// MARK: - Assets/Collections
public extension PhotoLibrary {
    
    public static func startCaching(assets: [PHAsset], size: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions? = nil) {
        shared.manager.startCachingImages(for: assets, targetSize: size, contentMode: contentMode, options: options)
    }
    
    public static func collections(with type: PHAssetCollectionType = .album, subtype: PHAssetCollectionSubtype = .any) -> [PHAssetCollection] {
        
        var collections: [PHAssetCollection] = []
        
        for type: PHAssetCollectionType in [.album, .smartAlbum] {
            let results = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: nil)
            collections.append(contentsOf: results.objects(at: IndexSet(integersIn: 0 ..< results.count)))
        }
        
        collections.sort { col1, col2 in
            if col1.localizedTitle?.lowercased() == "all photos" { return true }
            return false
        }
        
        return collections
    }
    
    public static func assets(in collection: PHAssetCollection) -> [PHAsset] {
        return collection.assets
    }
    
    public static var allAssets: [PHAsset] {
        var all = [PHAsset]()
        for collection in collections() {
            all.append(contentsOf: assets(in: collection))
        }
        return all
    }
}
