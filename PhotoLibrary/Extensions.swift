//
//  Extensions.swift
//  PhotoLibrary
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import Foundation
import Photos

public extension PHAsset {

    public func image(size: CGSize = PHImageManagerMaximumSize,
                      deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic,
                      synchronous: Bool = false,
                      progress: PHAssetImageProgressHandler? = nil,
                      _ completion: @escaping ((_ image: UIImage?, _ info: [AnyHashable : Any]?) -> ())) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode
        options.isSynchronous = synchronous
        options.isNetworkAccessAllowed = true
        options.progressHandler = progress
        
        PhotoLibrary.shared.manager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: options) { image, info in
            DispatchQueue.main.async {
                completion(image, info)
            }
        }
    }
    
    public func livePhoto(size: CGSize = PHImageManagerMaximumSize,
                          deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic,
                          progress: PHAssetImageProgressHandler? = nil,
                          _ completion: @escaping ((_ image: PHLivePhoto?, _ info: [AnyHashable : Any]?) -> ())) {
        
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = deliveryMode
        options.isNetworkAccessAllowed = true
        options.progressHandler = progress
        
        PhotoLibrary.shared.manager.requestLivePhoto(for: self, targetSize: size, contentMode: .aspectFit, options: options) { livePhoto, info in
            DispatchQueue.main.async {
                completion(livePhoto, info)
            }
        }
        
    }
    
    public var isLivePhoto: Bool {
        return PHAssetResource.assetResources(for: self).filter({
            $0.type == PHAssetResourceType.pairedVideo
        }).count > 0
    }
}



public extension PHAssetCollection {
    
    public var assets: [PHAsset] {
        return fetchAssets(max: Int.max)
    }
    
    public var newestAsset: PHAsset? {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(in: self, options: options).firstObject
    }
    
    public func fetchAssets(max: Int) -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = max
        let result = PHAsset.fetchAssets(in: self, options: options)
        
        return result.objects(at: IndexSet(integersIn: 0 ..< result.count))
    }
    
    public func coverImage(size: CGSize = PHImageManagerMaximumSize,
                    synchronous: Bool = false,
                    _ completion: @escaping ((_ image: UIImage?, _ info: [AnyHashable : Any]?) -> ())) {
        
        guard let asset = newestAsset else {
            completion(nil, nil)
            return
        }
        asset.image(size: size, synchronous: synchronous, completion)
    }
}
