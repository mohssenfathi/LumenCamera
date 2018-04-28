//
//  CameraManager.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import Foundation
import PhotoLibrary
import MTLImage
import MetalKit

class CameraManager {
    
    static let shared = CameraManager()
    
    static let albumName: String = "Lumen"
    let filterGroup = FilterGroup()
    let camera = Camera()
    var renderView: View!
    var mode: CameraMode = .normal {
        didSet { updateCameraMode() }
    }
    
    func initialize(with renderView: View) {
        
        self.renderView = renderView
        renderView.contentMode = .scaleAspectFit
        renderView.isZoomEnabled = false
        
        camera.isLivePhotoEnabled = true
        
        camera --> filterGroup --> renderView // Maybe add filter group in here
    }
 
    func updateCameraMode() {
        
        isNormalModeEnabled = mode == .normal
        isDepthModeEnabled = mode == .depth
        
        switch mode {
        case .fullscreen:
            renderView.contentMode = .scaleAspectFill
        default:
            renderView.contentMode = .scaleAspectFit
        }
    }
    
    func filter(image: UIImage, completion: @escaping (_ filteredImage: UIImage?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            let picture = Picture(image: image)
            picture.addTarget(self.filterGroup)
            self.filterGroup.process()
            let filtered = self.filterGroup.texture?.image
            DispatchQueue.main.async {
                completion(filtered)
            }
        }
    }
    
    // MARK: - Photo Capture
    func takePhoto(_ completion: @escaping CaptureCallback) {
        
        // Check setting later
        if camera.isLivePhotoEnabled {
            camera.takeLivePhoto() { (livePhoto, asset, metadata, error) in
                
                // TODO: Saving this to the library removes the live photo part
//                if let asset = asset {
//                    PhotoLibrary.saveAsset(asset, to: CameraManager.albumName, completion: { (success, error) in
//                        // TODO: Handle save error
//                    })
//                }
                
                // TODO: Live Photo Callback
            }
            
        } else {
            
            camera.takePhoto { photo, metadata, error in
                
                guard let photo = photo else {
                    completion(nil, metadata, error)
                    return
                }
                
//                self.filter(image: photo, completion: { filteredPhoto in
                self.filterGroup.filter(photo, completion: { filteredPhoto in
                    
                    guard let filteredPhoto = filteredPhoto else {
                        completion(nil, metadata, error)
                        return
                    }
                    
                    PhotoLibrary.savePhoto(filteredPhoto, to: CameraManager.albumName, completion: { (success, error) in
                        // TODO: Handle save error
                    })
                    
                    completion(filteredPhoto, metadata, error)
                })
                
            }
        }
    }
    
    func flip() {
        if isDepthModeEnabled {
            portrait.reset()
        }
        camera.flip()
    }

    
    // MARK: - Histogram
    let histogram = Histogram()
    var isHistogramEnabled: Bool = false {
        didSet {
            if isHistogramEnabled {
                if !filterGroup.filters.contains(histogram) {
                    filterGroup.add(histogram)
                }
            } else {
                filterGroup.remove(histogram)
            }
        }
    }
    
    // MARK: - Portrait
    let portrait = Portrait()
    
    var isDepthModeEnabled: Bool = false {
        didSet {
            if isDepthModeEnabled {
                
                portrait.reset()
                
                // TODO: .depthFront is crashing due to memory issues for some reason
                camera.mode = .depthRear
                
                if !filterGroup.filters.contains(portrait) {
                    filterGroup.insert(portrait, index: 0)
                }
            } else {
                filterGroup.remove(portrait)
            }
        }
    }
    
    var isNormalModeEnabled: Bool = true {
        didSet {
            if isNormalModeEnabled {
                camera.mode = .back
            }
        }
    }
}

enum CameraMode: String {
    case normal
    case fullscreen
    case depth
    case portrait
    
    var title: String {
        return rawValue.capitalized
    }
    
    static let all: [CameraMode] = [.fullscreen, .normal, .depth, .portrait]
}


struct CameraSetting {
    
    var isAuto: Bool = false
    var type: SettingType
    var isSelected: Bool = false
    var image: UIImage? { return type.image }
    var title: String? { return type.title }
    var selectionType: SelectionType {
        return type.selectionType
    }
    
    init(type: SettingType) {
        self.type = type
    }
    
    var subSettings: [SubSetting] {
        switch type {
        case .iso:
            return [isoAuto]
        case .exposure:
            return [evAuto]
        case .focus:
            return [focusAuto]
        case .flash:
            return [flashAuto, flashOn, flashOff]
        case .whiteBalance:
            return [whiteBalanceAuto]
        case .crop, .livePhoto, .zoom, .app, .histogram:
            return []
        }
    }
    
    var value: Float {
        set { setValue(newValue) }
        get { return getValue() }
    }
    
    /// Sets camera value corresponding to SettingType
    ///
    /// - Parameter value: Normalized value between 0 - 1
    private func setValue(_ value: Float) {
        switch type {
        case .iso:
            camera.iso = value
        case .exposure:
            camera.exposureDuration = Double(Tools.convert(value, oldMin: 0, oldMax: 1, newMin: 0.2, newMax: 0.6))
        case .zoom:
            camera.zoom = value
        case .livePhoto:
            break
        case .focus:
            camera.lensPosition = value
        case .whiteBalance:
            camera.setWhiteBalance(red: value, green: value, blue: value)
        case .histogram, .crop, .flash, .app:
            break
        }
    }
    
    private func setValue(_ value: Bool) {
        switch type {
        case .iso, .focus, .whiteBalance, .zoom, .exposure:
            break
        case .livePhoto:
            camera.isLivePhotoEnabled = value
        case .histogram, .crop, .flash, .app:
            break
        }
    }
    
    private func getValue() -> Float {
        switch type {
        case .iso:
            return camera.iso
        case .exposure:
            return Float(Tools.convert(camera.exposureDuration, oldMin: 0.2, oldMax: 0.6, newMin: 0, newMax: 0))
        case .zoom:
            return camera.zoom
        case .focus:
            return camera.lensPosition
        case .whiteBalance:
            return camera.whiteBalanceGains.redGain
        case .histogram, .crop, .flash, .app, .livePhoto:
            return 0.0
        }
    }
    
    enum SelectionType {
        
        // Selecting this settings will deselect other settings
        case exclusive
        
        // Selecting this settings will not deselect other settings
        case independant
        
        // Selecting this settings will deselect other settings,
        // this settings will perform an action then be deselected immediately
        case momentary
    }
    
    enum SettingType {
        
        case histogram
        case iso
        case exposure
        case crop
        case livePhoto
        case zoom
        case focus
        case flash
        case whiteBalance
        case app
        
        var image: UIImage? {
            switch self {
            case .iso: return nil
            case .exposure: return nil
            case .zoom: return nil
            case .focus: return #imageLiteral(resourceName: "focus")
            case .histogram: return #imageLiteral(resourceName: "histogram")
            case .crop: return #imageLiteral(resourceName: "crop")
            case .livePhoto: return #imageLiteral(resourceName: "live-photo")
            case .flash: return #imageLiteral(resourceName: "flash-on")
            case .whiteBalance: return #imageLiteral(resourceName: "temperature")
            case .app: return #imageLiteral(resourceName: "settings")
            }
        }
        
        var title: String? {
            switch self {
            case .iso: return "ISO"
            case .exposure: return "EV"
            case .zoom: return "Zoom"
            case .focus: return "Focus"
            case .histogram: return "Histogram"
            case .crop: return "Crop"
            case .livePhoto: return "Live Photo"
            case .flash: return "Flash"
            case .whiteBalance: return "White Balance"
            case .app: return "Settings"
            }
        }

        var selectionType: CameraSetting.SelectionType {
            switch self {
            case .iso, .exposure, .crop, .zoom,
                 .focus, .flash, .whiteBalance:
                return SelectionType.exclusive
            case .histogram, .livePhoto:
                return SelectionType.independant
            case .app:
                return SelectionType.momentary
            }
        }

    }
    
    struct SubSetting {
        var title: String?
        var image: UIImage?
        var isSelected: (() -> (Bool))
        var selectionHandler: ((SubSetting) -> ())
    }
    
    
    // MARK: - Subsettings
    let isoAuto = SubSetting(title: "Auto", image: #imageLiteral(resourceName: "AUTO"), isSelected: {
        return camera.isISOAuto
    }) { _ in
        camera.setISOAuto()
    }
    
    let evAuto = SubSetting(title: "Auto", image: #imageLiteral(resourceName: "AUTO"), isSelected: {
        return camera.isISOAuto
    }) { _ in
        camera.setExposureAuto()
    }
    
    let focusAuto = SubSetting(title: "Auto", image: #imageLiteral(resourceName: "AUTO"), isSelected: {
        return camera.isFocusAuto
    }) { _ in
        camera.setFocusAuto()
    }
    
    let flashAuto = SubSetting(title: "AUTO", image: nil, isSelected: {
        return camera.flashMode == .auto
    }) { _ in
        camera.flashMode = .auto
    }
    
    let flashOn = SubSetting(title: "ON", image: nil, isSelected: {
        return camera.flashMode == .on
    }) { _ in
        camera.flashMode = .on
    }
    
    let flashOff = SubSetting(title: "OFF", image: nil, isSelected: {
        return camera.flashMode == .off
    }) { _ in
        camera.flashMode = .off
    }

    let whiteBalanceAuto = SubSetting(title: "AUTO", image: nil, isSelected: {
        return camera.isWhiteBalanceAuto
    }) { _ in
        camera.setWhiteBalanceAuto()
    }
}

class CameraSettingObserver {
    
    // Add subsetting later?
    typealias ValueChangedHandler = ((_ setting: CameraSetting.SettingType, _ value: Float) -> ())
    
    let valueChangedHandler: ValueChangedHandler
    
    init(valueChangedHandler: @escaping ValueChangedHandler) {
        self.valueChangedHandler = valueChangedHandler
        setupObservers()
    }
    
    func setupObservers() {
        
        _ = camera.observe(\Camera.iso) { camera, value in
            if let value = value.newValue {
                self.valueChangedHandler(.iso, value)
            }
        }
        
    }
    
}


var camera: Camera { return CameraManager.shared.camera }
