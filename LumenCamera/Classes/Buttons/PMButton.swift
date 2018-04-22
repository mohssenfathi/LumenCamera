//
//  PMButton.swift
//  PokeMap
//


import UIKit

class PMButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        updateButtonState()
    }

    
    /// Overrides
    override var isSelected: Bool {
        didSet { updateButtonState() }
    }
    
    override var isHighlighted: Bool {
        didSet { updateButtonState() }
    }
    
    func updateButtonState() {
        if isSelected {
            selectedConfiguration(self)
        }
        else if isHighlighted {
            highlightedConfiguration(self)
        }
        else {
            normalConfiguration(self)
        }
    }
    
    
    /// Properties
    var normalConfiguration: ((_ button: PMButton) -> ()) = { _ in
        
    }
    var selectedConfiguration: ((_ button: PMButton) -> ()) = { _ in
        
    }
    var highlightedConfiguration: ((_ button: PMButton) -> ()) = { _ in
        
    }
}

class ForceTouchButton: PMButton {
    
    var force: CGFloat = 0.0
    var maximumForce: CGFloat = 10.0
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard traitCollection.forceTouchCapability == .available,
            let touch = touches.first
            else { return }
        
        maximumForce = touch.maximumPossibleForce
        force = touch.force
        
        sendActions(for: .valueChanged)
        
        if touch.force > touch.maximumPossibleForce/2.0 {
            sendActions(for: .primaryActionTriggered)
        }
    }
    
}

class DraggableButton: PMButton {
    
    var longPressGesture: UILongPressGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    
    var isDraggingEnabled: Bool = true
    
    override func setup() {
        super.setup()
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        addGestureRecognizer(longPressGesture)
        addGestureRecognizer(panGesture)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began { canDrag = true  }
//        if sender.state == .ended { canDrag = false }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard isDraggingEnabled, let superview = superview else { return }
        
        let translation = sender.translation(in: superview)
        
        var proposedCenter = center + translation
        proposedCenter.y = max(proposedCenter.y, bounds.height/2.0)
        proposedCenter.x = max(proposedCenter.x, bounds.width/2.0)
        proposedCenter.y = min(proposedCenter.y, superview.bounds.height - bounds.height/2.0)
        proposedCenter.x = min(proposedCenter.x, superview.bounds.width - bounds.width/2.0)
        center = proposedCenter
        
        sender.setTranslation(.zero, in: superview)
    }
    
}

class LMNSystemButton: PMButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage(image, for: .normal)
        setImage(image?.tinted(with: UIColor.lumenGrey(0.0)), for: .selected)
        
        normalConfiguration = {
            $0.layer.cornerRadius = $0.bounds.height/2.0
        }
        
        selectedConfiguration = {
            $0.backgroundColor = UIColor.lumenMint
        }
    }
}

class LMNRoundedButton: PMButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = layer.bounds.width/2.0
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
    }
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func +=(left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}



