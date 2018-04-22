//
//  SlideButton.swift
//  PokeMap
//
//  Created by Mohssen Fathi on 7/14/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

class SlideButton: UIControl {

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
        backgroundView.layer.cornerRadius = backgroundView.bounds.height/2.0
        updateHighlightView(false)
    }
    
    override var backgroundColor: UIColor? {
        set { backgroundView.backgroundColor = newValue }
        get { return backgroundView.backgroundColor }
    }
        
    func commonInit() {
        
        super.backgroundColor = .clear
        
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        backgroundView.layer.masksToBounds = true
        addSubview(backgroundView)
        
        highlightView.layer.masksToBounds = true
        highlightView.backgroundColor = highlightColor
        addSubview(highlightView)
        
        stackView = UIStackView(frame: bounds)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stackView)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideButton.handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    func reload() {
        
        for subview in stackView.subviews { subview.removeFromSuperview() }
        
        self.highlightView.backgroundColor = self.highlightViewColors?[self.selectedIndex] ?? self.highlightColor
        
        for (i, item) in items.enumerated() {
            
            let view = itemView?(item, i) ?? item.view(tinted: shouldTintImages)
            stackView.addArrangedSubview(view)
            
            if let button = view as? UIButton {
                button.tag = i
                button.tintColor = (i == selectedIndex) ? .white : (tintColors?[i] ?? tintColor)
                button.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
            }
        }

        selectedIndex = -1
        updateHighlightView(false)
    }
    
    @objc func didSelect(_ item: UIButton) {
        
        guard selectedIndex != item.tag else { return }
        
        selectedIndex = item.tag
        sendActions(for: .valueChanged)
        updateHighlightView(true)
    }
        
    func updateHighlightView(_ animated: Bool) {

        guard items.count > 0 else { return }
        
        UIView.animate(withDuration: animated ? 0.25 : 0.0,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.7,
                       options: .beginFromCurrentState,
                       animations: {
         
                        if self.selectedIndex < 0 {
                            self.highlightView.isHidden = true
                            for (i, item) in self.stackView.arrangedSubviews.enumerated() {
                                (item as? UIButton)?.tintColor = (self.tintColors?[i] ?? self.tintColor)
                            }
                            return
                        }
                        
                        self.highlightView.isHidden = false

                        self.highlightView.frame = CGRect(
                            x: 0, y: 0, width: self.itemWidth - self.highlightInset * 2.0,
                            height: self.bounds.height - self.highlightInset * 2.0
                        )
                        
                        self.highlightView.center = CGPoint(
                            x: self.itemWidth * CGFloat(self.selectedIndex) + self.itemWidth/2.0,
                            y: self.bounds.height/2.0
                        )
                        
                        self.highlightView.layer.cornerRadius = self.highlightView.bounds.height/2.0
                        self.highlightView.backgroundColor = self.highlightViewColors?[self.selectedIndex] ?? self.highlightColor
            
                        for (i, item) in self.stackView.arrangedSubviews.enumerated() {
                            (item as? UIButton)?.tintColor = (i == self.selectedIndex) ? .white : (self.tintColors?[i] ?? self.tintColor)
                        }
        }) { finished in
            
        }
        
    }
    
    var itemWidth: CGFloat {
        return bounds.width / CGFloat(items.count)
    }
    
    let highlightInset: CGFloat = 2.0
    
    
    // MARK: - Public
    
    var itemView: ((_ item: SlideButtonItem, _ index: Int) -> (UIView))?
    var selectedIndex: Int = -1
    var stackView: UIStackView!
    
    var items: [SlideButtonItem] = [] {
        didSet { reload() }
    }
    
    override var tintColor: UIColor! {
        didSet {
            // Dont really need to reload. Change this later
            reload()
        }
    }
    
    var shouldTintImages: Bool = true {
        didSet { reload() }
    }
    var tintColors: [UIColor]?
    var highlightColor: UIColor = UIColor.darkGray
    var highlightViewColors: [UIColor]?
    
    func selectIndex(_ index: Int) {
        selectedIndex = index
        updateHighlightView(true)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: sender.view)
        let translation = sender.translation(in: sender.view)
        let newX = highlightView.center.x + translation.x
        
        if newX - highlightView.bounds.width/2.0 > 0.0,
            newX + highlightView.bounds.width/2.0 < bounds.width {
            highlightView.center = CGPoint(x: newX, y: highlightView.center.y )
        }
        

        let index = Int((highlightView.center.x) / itemWidth)
        for (i, button) in stackView.arrangedSubviews.enumerated() where button is UIButton {
            let tint = (i == index) ? .white : (tintColors?[i] ?? tintColor)
            if button.tintColor != tint {
                button.tintColor = tint
            }
        }

        if selectedIndex == -1 {
            selectedIndex = Int(location.x / (stackView.bounds.width / CGFloat(items.count)))
            updateHighlightView(false)
        }
        
        if (sender.state == .ended || sender.state == .cancelled), index != selectedIndex {
            selectedIndex = index
            sendActions(for: .valueChanged)
            updateHighlightView(true)
        }
        
        sender.setTranslation(.zero, in: self)
    }
    
    // MARK: - Private
    private var backgroundView = UIView()
    private let highlightView = UIView()
    private var panGesture: UIPanGestureRecognizer!
}


protocol SlideButtonItem {
    var title: String?  { get }
    var image: UIImage? { get }
}

extension String: SlideButtonItem {
    var title: String? { return self }
    var image: UIImage? { return nil }
}

extension UIImage: SlideButtonItem {
    var title: String? { return nil }
    var image: UIImage? { return self }
}

extension UIButton: SlideButtonItem {
    var title: String? { return title(for: .normal) }
    var image: UIImage? { return image(for: .normal) }
}

extension SlideButtonItem {
    
    func view(tinted: Bool = true) -> UIView {
        
        let button = UIButton(type: tinted ? .system : .custom)
        button.contentHorizontalAlignment = .center
        button.tintColor = .black
        
        if title != nil {
            button.setTitle(title, for: .normal)
            button.titleLabel?.textAlignment = .center
        } else {
            button.setImage(image, for: .normal)
        }

        return button
    }
}
