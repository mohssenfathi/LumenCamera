//
//  PanSlider.swift
//  Lumen
//
//  Created by Mohssen Fathi on 2/11/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Tools

@IBDesignable
class PanSlider: UIControl {
    
    var view: UIView!
    var bar: UIView = UIView()
    
    @IBInspectable var barColor: UIColor = .blue {
        didSet { bar.backgroundColor = barColor }
    }
    
    @IBInspectable var minimumValue: Float = 0.0 {
        didSet {
            if minimumValue > maximumValue {
                minimumValue = maximumValue
            }
        }
    }
    
    @IBInspectable var maximumValue: Float = 1.0 {
        didSet {
            if maximumValue < minimumValue {
                maximumValue = minimumValue
            }
        }
    }
    
    @IBInspectable var value: Float = 0.5 {
        didSet {
            Tools.clamp(&value, low: minimumValue, high: maximumValue)
            bar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width * CGFloat(value), height: self.frame.height)
            sendActions(for: .valueChanged)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            panGestureRecognizer.isEnabled = isEnabled
        }
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer! {
        didSet {
            panGestureRecognizer.addTarget(self, action: #selector(PanSlider.handlePanGesture(_:)))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        
        view = UIView()
        view.backgroundColor = backgroundColor
        addSubview(view)
        
        bar.frame = CGRect(x: 0, y: 0, width: 1.0, height: self.frame.height)
        bar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bar.backgroundColor = barColor
        view.addSubview(bar)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        if sender.state == .changed {
            value += Float(translation.x/frame.size.width)/1.5
        }
        sender.setTranslation(CGPoint.zero, in: sender.view)
    }
    
    override var canBecomeFocused: Bool {
        return false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        view.frame = rect
        bar.frame = CGRect(x: 0, y: 0, width: rect.size.width * CGFloat(value), height: self.frame.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
        view.backgroundColor = backgroundColor
        bar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width * CGFloat(value), height: self.frame.height)
    }
    
}

