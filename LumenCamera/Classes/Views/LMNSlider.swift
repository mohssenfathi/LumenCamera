//
//  LMNSlider.swift
//  Lumen
//
//  Created by Mohssen Fathi on 10/26/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

@IBDesignable
class LMNSlider: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateValueTrack()
        updateThumbPosition()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: classForCoder), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        drawView()
    }
    
    func drawView() {

        /// Track View
        trackView.layer.masksToBounds = true
        trackView.layer.cornerRadius = trackView.bounds.height/2.0
        trackWidth = 3.0
        
        thumbView.layer.masksToBounds = true
        thumbView.layer.cornerRadius = thumbWidth/2.0
        thumbWidth = 22.0
        thumbBorderColor = .black
        thumbBorderWidth = 1.0
        
        valueTrackLayer.frame = valueTrack.bounds
        valueTrackLayer.fillColor = nil
        valueTrackColor = .white
        valueTrack.layer.addSublayer(valueTrackLayer)

        minimumValue = 0.0
        maximumValue = 1.0
        defaultValue = 0.5
        value = 0.5
        
        updateValueTrack()
    }
    
    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let dx = sender.translation(in: sender.view).x
        
        let proposed = max(min(thumbLeadingConstraint.constant + dx, contentWidth), 0)
        thumbLeadingConstraint.constant = proposed
        
        updateValueTrack()
        
        if isContinuous {
            sendActions(for: .valueChanged)
        }
        
        sender.setTranslation(.zero, in: sender.view)
    }
    
    var value: Float {
        get {
            return normalizedValue * (maximumValue - minimumValue) + minimumValue
        }
        set {
            thumbLeadingConstraint.constant = (CGFloat(newValue - minimumValue) / CGFloat(maximumValue - minimumValue)) * contentWidth
            updateValueTrack()
        }
    }

    
    /// Public
    var minimumValue: Float = 0.0
    var maximumValue: Float = 1.0
    var defaultValue: Float = 0.5 {
        didSet { updateValueTrack() }
    }
    
    var isContinuous: Bool = true
    
    @IBInspectable var trackWidth: CGFloat = 3.0 {
        didSet {
            trackWidthConstraint.constant = trackWidth
            valueTrackLayer.lineWidth = trackWidth
            updateValueTrack()
        }
    }
    @IBInspectable var trackColor: UIColor = .black {
        didSet { trackView.backgroundColor = trackColor }
    }
    @IBInspectable var valueTrackColor: UIColor = .white {
        didSet {
            valueTrackLayer.strokeColor = valueTrackColor.cgColor
            updateValueTrack()
        }
    }
    @IBInspectable var thumbWidth: CGFloat = 22.0 {
        didSet {
            thumbWidthConstraint.constant = thumbWidth
            trackViewLeadingConstraint.constant = thumbWidth/2.0
            trackViewTrailingConstraint.constant = thumbWidth/2.0
        }
    }
    @IBInspectable var thumbColor: UIColor = .white {
        didSet { thumbView.backgroundColor = thumbColor }
    }
    @IBInspectable var thumbBorderColor: UIColor = .white {
        didSet { thumbView.layer.borderColor = thumbBorderColor.cgColor }
    }
    @IBInspectable var thumbBorderWidth: CGFloat = 1.0 {
        didSet { thumbView.layer.borderWidth = thumbBorderWidth }
    }
    
    func update() {
        updateValueTrack()
        updateThumbPosition()
    }
    
    /// Private
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet private weak var trackView: UIView!
    @IBOutlet private weak var thumbView: UIView!
    @IBOutlet private weak var thumbTouchView: UIView!
    @IBOutlet private weak var trackWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var thumbWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var thumbLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var valueTrack: UIView!
    
    private var valueTrackLayer = CAShapeLayer()
    private var valueTrackPath = UIBezierPath()
    
    private func updateThumbPosition() {
        thumbLeadingConstraint.constant = CGFloat(value - minimumValue) * contentWidth
    }
    
    private func updateValueTrack() {
        valueTrackPath.removeAllPoints()
        
        let y = trackView.bounds.height/2.0
        let startX = CGFloat(normalize(value: defaultValue)) * contentWidth
        let endX = CGFloat(normalizedValue) * contentWidth
        valueTrackPath.move(to: CGPoint(x: startX, y: y))
        valueTrackPath.addLine(to: CGPoint(x: endX, y: y))
        
        valueTrackLayer.path = valueTrackPath.cgPath
    }
    
    private var contentWidth: CGFloat {
        return trackView.bounds.width
    }
    
    
    private var normalizedValue: Float {
        return Float(thumbLeadingConstraint.constant/contentWidth)
    }
    
    private func normalize(value: Float) -> Float {
        return (value - minimumValue) / (maximumValue - minimumValue)
    }
}

