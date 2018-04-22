//
//  DialSlider.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 9/20/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit
import Tools

@IBDesignable
class DialSlider: UIControl {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var dialContainer: UIView!
    @IBOutlet var sliderHeight: NSLayoutConstraint!
    @IBOutlet var defaultMarker: UIView!
    @IBOutlet var gradientView: UIView!
    
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
        reload()
    }
    
    func commonInit() {
        
        Bundle.main.loadNibNamed(String(describing: classForCoder), owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        defaultMarker.layer.masksToBounds = true
        defaultMarker.layer.cornerRadius = defaultMarker.bounds.height/2.0
        
        scrollView.decelerationRate = 0.990
        
        backgroundColor = .clear
        
        reload()
    }
    
    func reload() {
        setupGradient()
        drawDial()
    }
    
    func setupGradient() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(edgeGradientAlpha).cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(edgeGradientAlpha).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.mask = gradientLayer
    }
    
    
    
    // MARK: - Properties
    var minimumValue: CGFloat = 0.0
    var maximumValue: CGFloat = 1.0
    var value: CGFloat {
        get {
            return value(forOffset: scrollView.contentOffset.y)
        }
        set {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: offset(from: newValue))
        }
    }
    
    var edgeGradientAlpha: CGFloat = 0.3 {
        didSet { setupGradient() }
    }
    
    var increment: CGFloat = 0.02
    var longLineInterval: Int = 5
    var lineSpacing: CGFloat = 20.0
    
    // Short Lines
    var shortLineWidth: CGFloat = 2.0
    var shortLineLength: CGFloat = 15.0
    var shortLineColor: UIColor = .lightGray
    
    // Long Lines
    var longLineWidth: CGFloat = 3.0
    var longLineLength: CGFloat = 25.0
    var longLineColor: UIColor = .white
    
    
    enum Mode {
        case none
        case continuous
        case everyLine
        case longLinesOnly
    }
    
    /*
     Specifies when this control causes a selection feedback generation
         - .none: Haptic feedback will never be sent
         - .continuous: You should never do this
         - .everyLine: haptic feedback is sent every time the default indicator crosses a long or short line
         - .longLinesOnly: haptic feedback is sent only when the default indicator crosses a long line
     */
    var hapticMode: Mode = .longLinesOnly
    
    /*
     Specifies when this control should send actions for valueChanged event
         - .none: You don't want this, events will never be sent
         - .continuous: action events are sent every time the scrollView's contentOffset changes
         - .everyLine: action events are sent every time the default indicator crosses a long or short line
         - .longLinesOnly: action events are sent only when the default indicator crosses a long line
     */
    var actionMode: Mode = .continuous
    
    /*
     Determines where value should `snap` to upon drag end
         - .none and .continuous are the same in this context, no snapping
         - .everyLine will snap to all lines, long and short
         - .longLinesOnly will snap only to long lines, duh
     */
    var snapMode: Mode = .none
    
    
    
    
    
    // MARK: - Private
    private func drawDial() {
        
        for sublayer in dialContainer.layer.sublayers ?? [] { sublayer.removeFromSuperlayer() }
        lines.removeAll()
        
        scrollView.frame = bounds
        contentView.frame = bounds
        
        let start = edgeSpace + longLineWidth/2.0
        let end = totalWidth - edgeSpace - longLineWidth/2.0
        var line: CAShapeLayer!
        let width = scrollView.bounds.width
        
        sliderHeight.constant = totalWidth
        
        for i in 0 ..< numberOfLines {
        
            let percentage = CGFloat(i) / CGFloat(numberOfLines - 1)
            let y = percentage * (end - start) + start
            
            if i % longLineInterval == 0 {
                line = drawLine(
                    lineWidth: longLineWidth,
                    color: longLineColor,
                    from: CGPoint(x: (width - longLineLength)/2.0, y: y),
                    to: CGPoint(x: longLineLength, y: y),
                    in: dialContainer
                ).first!
            }
            else {
                line = drawLine(
                    lineWidth: shortLineWidth,
                    color: shortLineColor,
                    from: CGPoint(x: (width - shortLineLength)/2.0, y: y),
                    to: CGPoint(x: shortLineLength, y: y),
                    in: dialContainer
                ).first!
            }
            
            lines.append(line)
        }
    }
    
    private func normalizedValue(forOffset offset: CGFloat) -> CGFloat {
        
        let start = edgeSpace + longLineWidth/2.0
        let end = totalWidth - edgeSpace - longLineWidth/2.0
        let range = end - start
        
        var nv = Tools.convert(offset, oldMin: 0, oldMax: range, newMin: 0.0, newMax: 1.0)
        Tools.clamp(&nv, low: 0.0, high: 1.0)
        
        return nv
    }
    
    private func offset(from normalizedValue: CGFloat) -> CGFloat {
        
        let start = edgeSpace + longLineWidth/2.0
        let end = totalWidth - edgeSpace - longLineWidth/2.0
        let range = end - start
        
        var nv = Tools.convert(normalizedValue, oldMin: 0.0, oldMax: 1.0, newMin: 0.0, newMax: range) + start
        Tools.clamp(&nv, low: start, high: range + start)
        
        return nv
    }
    
    private func value(forOffset offset: CGFloat) -> CGFloat {
        let val = normalizedValue(forOffset: offset)
        return Tools.convert(val, oldMin: 0, oldMax: 1, newMin: minimumValue, newMax: maximumValue)
    }
 
    private let impactGenerator = UISelectionFeedbackGenerator()
    private var edgeSpace: CGFloat { return scrollView.bounds.height/2.0 }
    private var numberOfLines: Int { return Int((maximumValue - minimumValue) / increment) + 1 }
    private var totalWidth: CGFloat { return CGFloat(numberOfLines - 1) * lineSpacing + edgeSpace }
    private var lastBucket: Int = 0
    private var lines: [CAShapeLayer] = []
}



extension DialSlider: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let val = normalizedValue(forOffset: scrollView.contentOffset.y)
        let bucket = Int(val / (1.0 / CGFloat(numberOfLines)))
        
        /// Action Feedback
        switch actionMode {
        case .continuous:
            sendActions(for: .valueChanged)
        case .everyLine:
            if bucket != lastBucket {
                sendActions(for: .valueChanged)
            }
        case .longLinesOnly:
            if bucket != lastBucket, bucket % longLineInterval == 0 {
                sendActions(for: .valueChanged)
            }
        case .none:
            break
        }
        
        
        /// Haptic Feedback
        switch hapticMode {
        case .none:
            break
        case .continuous:
            // You probably don't want to do this
            break
        case .everyLine:
            if bucket != lastBucket {
                impactGenerator.selectionChanged()
            }
        case .longLinesOnly:
            if bucket != lastBucket, bucket % longLineInterval == 0 {
                impactGenerator.selectionChanged()
            }
        }
        
        lastBucket = bucket
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard snapMode != .none, snapMode != .continuous else { return }
        
        let target = targetContentOffset.pointee.y
        
        guard let newTarget = lines.enumerated().filter({
            
            // Account for snap mode
            if snapMode == .everyLine { return true }
            return $0.offset % longLineInterval == 0
            
        }).map({
            
            // Map to middle of each line
            $0.element.path?.boundingBox.midY
            
        }).compactMap({ $0 }).filter({
            
            // Select next line after target content offset, accounting for direction
            if velocity.y > 0 {
                return $0 > target
            } else {
                return $0 < target
            }
            
        }).first else {
            return
        }
        
        var i = 0
        for line in lines {
            if line.path!.boundingBox.midY == newTarget { break }
            i += 1
        }
        
        print("Line: \(i), Offset: \(newTarget)")
        
//        newTarget -= lineSpacing
//        Tools.clamp(&newTarget, low: edgeSpace, high: totalWidth - edgeSpace * 2.0)
        
        targetContentOffset.pointee = CGPoint(x: targetContentOffset.pointee.x, y: newTarget)
    }
    
}




extension DialSlider {
    // MARK: - Drawing Helpers
    
    @discardableResult
    func drawLine(lineWidth: CGFloat, color: UIColor, outlineColor: UIColor? = nil, from startPoint: CGPoint, to endPoint: CGPoint, in view: UIView) -> [CAShapeLayer] {
    
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        var shapeLayers: [CAShapeLayer] = []
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = "round"
        
        shapeLayers.append(shapeLayer)
        
        if let outlineColor = outlineColor {
            let shapeLayerOutline = CAShapeLayer()
            shapeLayerOutline.path = path.cgPath
            shapeLayerOutline.strokeColor = outlineColor.cgColor
            shapeLayerOutline.lineWidth = lineWidth + 0.5
            shapeLayerOutline.lineCap = "round"
            view.layer.addSublayer(shapeLayerOutline)
            shapeLayers.append(shapeLayerOutline)
        }
        
        view.layer.addSublayer(shapeLayer)
    
        return shapeLayers
    }
}
