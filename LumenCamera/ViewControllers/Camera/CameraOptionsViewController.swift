//
//  CameraOptionsViewController.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import MTLImage

typealias CameraSelectionHandler = ((CameraSetting, CameraSetting.SubSetting?) -> ())

class CameraOptionsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var collapsedExpandButtonContainer: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var collapsedExpandButton: UIButton!
    @IBOutlet weak var subSettingsCollectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var swipeHintContainer: UIView!
    
    var expandHandler: ((_ expand: Bool) -> ())?
    
    var cameraSettingsObserver: CameraSettingObserver!
    var selectionHandler: CameraSelectionHandler?
    var settingsDataSource: CameraSettingsDataSource!
    var subSettingsDataSource: CameraSubSettingsDataSource!
    var currentSetting: CameraSetting?
    var cameraViewController: CameraViewController? {
        return parent as? CameraViewController
    }
    var isExpanded: Bool = true {
        didSet {
            if isExpanded != oldValue { expand(isExpanded) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsDataSource = CameraSettingsDataSource { setting, subSetting  in
            
            if setting.selectionType == .exclusive {                
                self.currentSetting = setting
                self.subSettingsDataSource.subSettings = setting.isSelected ? setting.subSettings : []
                self.showSubSettingsCollectionView(setting.isSelected)
            }

            self.selectionHandler?(setting, subSetting)
        }
        
        subSettingsDataSource = CameraSubSettingsDataSource(collectionView: subSettingsCollectionView) { subSetting in
            
            // TODO: pass this into selectionHandler later
            subSetting.selectionHandler(subSetting)
        }
        
        collectionView.dataSource = settingsDataSource
        collectionView.delegate = settingsDataSource
        subSettingsCollectionView.dataSource = subSettingsDataSource
        subSettingsCollectionView.delegate = subSettingsDataSource
        
        subSettingsCollectionView.isHidden = true
        swipeHintContainer.isHidden = true
        
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePreferredContentSize()
        if camera.isLivePhotoEnabled {
            select(settingType: .livePhoto)
        }
    }
    
    func select(settingType: CameraSetting.SettingType) {
        guard let index = settingsDataSource.settings.enumerated().filter({ $0.element.type == settingType }).first?.offset else {
            return
        }
        settingsDataSource.settings[index].isSelected = true
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    @IBAction func expandButtonPressed(_ sender: UIButton) {
        toggle()
    }
    
    func toggle() {
        isExpanded = !isExpanded
        expandHandler?(isExpanded)
    }
    
    func expand(_ expand: Bool) {
     
        if !expand {
            showSubSettingsCollectionView(false)
        } else if (currentSetting?.subSettings.count ?? 0) > 0 {
            showSubSettingsCollectionView(true)
        }
        
        expandButton.setImage(expand ? #imageLiteral(resourceName: "chevron-up-wide") : #imageLiteral(resourceName: "chevron-down-wide"), for: .normal)
        collapsedExpandButton.setImage(expand ? #imageLiteral(resourceName: "chevron-up-wide") : #imageLiteral(resourceName: "chevron-down-wide"), for: .normal)
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState], animations: {
            self.view.transform = expand ? .identity : CGAffineTransform(translationX: 0, y: -self.collectionView.bounds.height - 8)
            self.collectionView.alpha = expand ? 1.0 : 0.0
            self.collapsedExpandButtonContainer.alpha = expand ? 0.0 : 1.0
            self.blurView.alpha = expand ? 1.0 : 0.0
        }) { _ in
            
        }
    }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSize(width: blurView.bounds.width, height: blurView.frame.maxY)
        self.cameraViewController?.updateSnapViewInsets()
    }
    
    func showSubSettingsCollectionView(_ show: Bool, animated: Bool = true, completion: (() -> ())? = nil) {
        animate(duration: 0.15, {
            self.subSettingsCollectionView.isHidden = !show
        }) {
            completion?()
        }
    }
}

class CameraSettingsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var selectionHandler: CameraSelectionHandler
    let settingTypes: [CameraSetting.SettingType] = [.histogram, .exposure, .iso, .livePhoto, .focus, .flash, .app]
    var settings: [CameraSetting]
    
    init(selectionHandler: @escaping CameraSelectionHandler) {
        self.selectionHandler = selectionHandler
        
        settings = settingTypes.map {
            CameraSetting(type: $0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(settings.count)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? ButtonCell else {
            return
        }
        
        let setting = settings[indexPath.item]
        if let image = setting.image {
            cell.image = image
            cell.title = nil
        } else {
            cell.image = nil
            cell.title = setting.title
        }
        
        cell.isSelected = setting.isSelected
        cell.selectedColor = UIColor.lumenGold
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var setting = settings[indexPath.item]
        
        switch setting.selectionType {
        case .momentary:
            setting.isSelected = false
            collectionView.deselectItem(at: indexPath, animated: true)
        case .exclusive:
            setting.isSelected = !setting.isSelected
            for ip in collectionView.indexPathsForVisibleItems {
                if ip != indexPath, settings[ip.item].selectionType != .independant {
                    collectionView.deselectItem(at: ip, animated: true)
                }
            }
        case .independant:
            setting.isSelected = !setting.isSelected
            break
        }
 
        selectionHandler(setting, setting.subSettings.first)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        var setting = settings[indexPath.item]
        setting.isSelected = false
        
        selectionHandler(setting, setting.subSettings.first)
    }
}

class CameraSubSettingsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var subSettings: [CameraSetting.SubSetting] = [] {
        didSet { collectionView.reloadSections(IndexSet(integer: 0)) }
    }
    var selectionHandler: ((CameraSetting.SubSetting) -> ())
    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView, selectionHandler: @escaping ((CameraSetting.SubSetting) -> ())) {
        self.collectionView = collectionView
        self.selectionHandler = selectionHandler
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / CGFloat(subSettings.count)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subSettings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? ButtonCell else { return }
        
        let subSetting = subSettings[indexPath.item]
        cell.selectedColor = UIColor.lumenGold
        cell.isSelected = subSetting.isSelected()
        cell.isHidden = false
        
        if let image = subSetting.image {
            cell.image = image
            cell.title = nil
        } else {
            cell.image = nil
            cell.title = subSetting.title
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subSetting = subSettings[indexPath.item]
        selectionHandler(subSetting)
    }
}

