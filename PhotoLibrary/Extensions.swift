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
    
    public func depthData(completion: @escaping (AVDepthData?) -> ()) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        PhotoLibrary.shared.manager.requestImageData(for: self, options: options) { (data, dataType, orientation, info) in
            
            guard let data = data, let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                completion(nil)
                return
            }
            
            
            guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
                completion(nil)
                return
            }

            var depthData = try? AVDepthData(fromDictionaryRepresentation: auxDataInfo)
//            if depthData?.depthDataType != kCVPixelFormatType_DisparityFloat16 {
//                depthData = depthData?.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat16)
//            }
            
            completion(depthData)
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


extension CVPixelBuffer {
    
    public func normalize() {
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        var minPixel: Float = 1.0
        var maxPixel: Float = 0.0
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixel = floatBuffer[y * width + x]
                minPixel = min(pixel, minPixel)
                maxPixel = max(pixel, maxPixel)
            }
        }
        
        let range = maxPixel - minPixel
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixel = floatBuffer[y * width + x]
                floatBuffer[y * width + x] = (pixel - minPixel) / range
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    func printDebugInfo() {
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let totalBytes = CVPixelBufferGetDataSize(self)
        
        print("Depth Map Info: \(width)x\(height)")
        print(" Bytes per Row: \(bytesPerRow)")
        print("   Total Bytes: \(totalBytes)")
    }
    
    public func convertToDisparity32() -> CVPixelBuffer? {
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        
        var dispartyPixelBuffer: CVPixelBuffer?
        
        let _ = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_DisparityFloat32, nil, &dispartyPixelBuffer)
        
        guard let outputPixelBuffer = dispartyPixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(outputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 1))
        
        let outputBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(outputPixelBuffer), to: UnsafeMutablePointer<Float>.self)
        let inputBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<UInt8>.self)
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let pixel = inputBuffer[y * width + x]
                outputBuffer[y * width + x] = (Float(pixel) / Float(UInt8.max))
            }
        }
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 1))
        CVPixelBufferUnlockBaseAddress(outputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return dispartyPixelBuffer
    }
}
