//
//  CameraViewController.swift
//  Lumen Camera
//
//  Created by Mohssen Fathi on 3/10/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import MTLImage
import AVFoundation

class CameraViewController: BaseViewController {
    
    @IBOutlet weak var telephotoButton: TelephotoButton!
    @IBOutlet weak var settingsPanGesture: UIPanGestureRecognizer!
    @IBOutlet weak var renderView: View!
    @IBOutlet weak var slider: PanSlider!
    @IBOutlet weak var modeCollectionView: UICollectionView!
    @IBOutlet weak var modeContainer: UIView!
    @IBOutlet weak var modeViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsContainer: UIView!
    @IBOutlet weak var renderViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitFullscreenButton: UIButton!
    @IBOutlet weak var captureButton: CaptureButton!
    @IBOutlet weak var histogramView: HistogramView!
    @IBOutlet weak var histogramContainerView: SnappableView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet var fullscreenHide: [UIView]!
    
    var cameraOptionsViewController: CameraOptionsViewController?
    var modesDataSource: CameraModesDataSource!
    let modes = CameraMode.all
    var mode: CameraMode {
        set {
            CameraManager.shared.mode = newValue
            updateMode()
        }
        get { return CameraManager.shared.mode }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        
        exitFullscreenButton.layer.masksToBounds = true
        exitFullscreenButton.layer.cornerRadius = exitFullscreenButton.bounds.width/2.0
        exitFullscreenButton.backgroundColor = UIColor.lumenGrey(0.0).withAlphaComponent(0.7)
        
        view.addBackgroundGradient(from: 0.05, to: 0.0)
        
        CameraManager.shared.histogram.newHistogramAvailable = { data in
            self.histogramView.update(with: data)
        }
        
        modesDataSource = CameraModesDataSource(collectionView: modeCollectionView, modes: modes, selectionHandler: { mode in
            self.mode = mode
        })
        
        modeCollectionView.dataSource = modesDataSource
        modeCollectionView.delegate = modesDataSource
        
        CameraManager.shared.initialize(with: renderView)
        
        modesDataSource.select(mode: .normal)
        updateMode()
    }
    
    
    func handleSelection(setting: CameraSetting) {

        // TODO: Move these to camera manager
        if setting.type == .histogram {
            self.updateSnapViewInsets()
            CameraManager.shared.isHistogramEnabled = setting.isSelected
            self.histogramContainerView.isHidden = !setting.isSelected
        }
        else if setting.type == .livePhoto {
            camera.isLivePhotoEnabled = setting.isSelected
        }
        else if setting.type == .app {
            performSegue(withIdentifier: "Settings", sender: self)
        }
    }
    
    // MARK: - Mode
    func updateMode() {

        telephotoButton.isHidden = !camera.isModeSupported(.telephoto)
        
        if let height = cameraOptionsViewController?.preferredContentSize.height {
            optionsContainerHeightConstraint.constant = height
        }
        
        switch mode {
        case .fullscreen:
            renderViewCenterYConstraint.constant = 0.0
            showFullscreen(true)
            captureButton.isInverted = true
        case .depth:
            telephotoButton.setTitle(nil, for: .normal)
            telephotoButton.setImage(#imageLiteral(resourceName: "depth"), for: .normal)
        default:
            telephotoButton.setImage(nil, for: .normal)
            telephotoButton.setTitle(camera.mode == .telephoto ? "1x" : "2x", for: .normal)

            renderViewCenterYConstraint.constant = -30.0
            showFullscreen(false)
            captureButton.isInverted = false
        }
        
    }
    
    func updateSnapViewInsets() {
        if let snapContainer = histogramContainerView.superview, let optionsContentSize = cameraOptionsViewController?.preferredContentSize {
            let snapY = self.view.convert(snapContainer.frame, from: snapContainer.superview).minY
            let top: CGFloat = max(12, optionsContentSize.height - snapY + 12)
            histogramContainerView.snapInsets = UIEdgeInsetsMake(top, 12, 12, 12)
        }
    }
    
    // MARK: - Actions
    @IBAction func sliderValueChanged(_ sender: PanSlider) {
        // TEMP
        CameraManager.shared.portrait.focus = sender.value
//        CameraManager.shared.portrait.blend.mix = sender.value
//        currentSetting?.value = sender.value
    }
    
    @IBAction func exitFullscreen(_ sender: UIButton) {
        modesDataSource.select(mode: .normal)
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        RootCoordinator.shared.scroll(to: .library, animated: true)
    }
    
    @IBAction func captureButtonPressed(_ sender: CaptureButton) {
        
        CameraManager.shared.takePhoto { (photo, metadata, error) in
            
        }
    }
    
    @IBAction func telephotoButtonPressed(_ sender: UIButton) {
        if mode == .depth {
            CameraManager.shared.portrait.showRawDepth = false
        }
        else if camera.mode == .telephoto {
            sender.setTitle("1x", for: .normal)
            camera.mode = .back
        } else {
            sender.setTitle("2x", for: .normal)
            camera.mode = .telephoto
        }
    }
    
    @IBAction func depthButtonTouchDown(_ sender: UIButton) {
        if mode == .depth {
            CameraManager.shared.portrait.showRawDepth = true
        }
    }
    
    
    // MARK: - Gesture Recognizers
    @IBAction func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        
        if let index = modes.index(of: mode) {
            if sender.direction == .left, index + 1 < modes.count {
                modesDataSource.select(mode: modes[index + 1])
            }
            else if sender.direction == .right, index > 0 {
                modesDataSource.select(mode: modes[index - 1])
            }
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: sender.view)
        
        let delta = translation.x/view.bounds.width
        slider.value = slider.value + Float(delta)
        
        sender.setTranslation(.zero, in: sender.view)
    }

    @IBAction func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        CameraManager.shared.flip()
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        // Need to check if actually options container
         optionsContainerHeightConstraint.constant = container.preferredContentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CameraOptionsViewController {
            cameraOptionsViewController = vc
            
            cameraOptionsViewController?.selectionHandler = { setting, subSetting in
                self.currentSetting = setting
                self.handleSelection(setting: setting)
            }
            
            cameraOptionsViewController?.expandHandler = { isExpanded in

            }
        }
    }
    
    private var currentSetting: CameraSetting?
}


// MARK: - Options View
extension CameraViewController {
    
    var optionsViewContentHeight: CGFloat {
        return cameraOptionsViewController?.preferredContentSize.height ?? optionsContainer.bounds.height
    }
}


// MARK: - Animations
extension CameraViewController {
    
    func showFullscreen(_ show: Bool, after delay: Double = 0.0, animated: Bool = true, completion: (() -> ())? = nil) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            self.cameraOptionsViewController?.isExpanded = !show
            self.modeViewBottomConstraint.constant = show ? -self.modeContainer.bounds.height + 12.0 : 0.0
            self.view.setNeedsUpdateConstraints()
            
            guard animated else { return }
            
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState], animations: {
                self.view.layoutSubviews()
                self.exitFullscreenButton.alpha = show ? 1.0 : 0.0
                self.fullscreenHide.forEach { $0.alpha = show ? 0.0 : 1.0 }
            }) { _ in
                completion?()
            }
        }
        
    }
    
    func showModeView(_ show: Bool, after delay: Double = 0.0, animated: Bool = true, completion: (() -> ())? = nil) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let to = show ? 0.0 : -self.modeContainer.bounds.height
            self.animateConstraint(self.modeViewBottomConstraint, to: to, duration: 0.35, animated: animated, completion: completion)
        }
    }
    
}


class CameraModesDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let modes: [CameraMode]
    let collectionView: UICollectionView
    let itemWidth: CGFloat = 130.0
    var selectionHandler: ((CameraMode) -> ())
    
    init(collectionView: UICollectionView, modes: [CameraMode], selectionHandler: @escaping ((CameraMode) -> ())) {
        self.collectionView = collectionView
        self.modes = modes
        self.selectionHandler = selectionHandler
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (collectionView.bounds.width - itemWidth)/2.0
        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as? ButtonCell else {
            return UICollectionViewCell()
        }
        
        let mode = modes[indexPath.item]
        cell.title = mode.title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(at: indexPath)
    }
    
    
    func select(mode: CameraMode) {
        guard let index = modes.index(of: mode) else { return }
        selectItem(at: IndexPath(item: index, section: 0))
    }
    
    func selectItem(at indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        selectionHandler(modes[indexPath.item])
    }
    
}


extension CameraViewController: UIGestureRecognizerDelegate {
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer is UISwipeGestureRecognizer {
//            return true
//        }
//        return false
//    }
    
}
