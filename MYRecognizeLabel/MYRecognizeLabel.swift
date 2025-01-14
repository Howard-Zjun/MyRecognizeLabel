//
//  MYRecognizeLabel.swift
//  ListenSpeak
//
//  Created by Howard-Zjun on 2025/1/9.
//

import UIKit

class MYRecognizeLabel: UILabel {

    var needRecognize: Bool = false
    
    var detectionBlock: ((String, NSRange) -> Void)?

    let manager: MYRecognizelManager = .init()
    
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .init(x: 0, y: 0, width: kwidth, height: kheight), textContainer: manager.textContainer)
        textView.backgroundColor = .clear
        textView.textColor = .clear
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(textView)
        manager.update(width: kwidth)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        manager.update(width: kwidth)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(textView)
        manager.update(width: kwidth)
    }
    
    override func layoutSubviews() {
        textView.kwidth = kwidth
        textView.kheight = kheight
        manager.update(width: kwidth)
    }
    
    override var text: String? {
        didSet {
            isUserInteractionEnabled = true
            guard let text else { return }
            
            manager.set(text: text, font: font)
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            isUserInteractionEnabled = true
            guard let attributedText else { return }
            
            manager.set(attr: attributedText, font: font)
        }
    }
    
    override var font: UIFont! {
        didSet {
            textView.font = font
            
            if let text {
                manager.set(text: text, font: font)
            } else if let attributedText {
                manager.set(attr: attributedText, font: font)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard needRecognize else {
            super.touchesEnded(touches, with: event)
            return
        }
        guard let location = touches.first?.location(in: self) else {
            super.touchesEnded(touches, with: event)
            return
        }
        
        if !CGRectContainsPoint(textView.frame, location) {
           return
        }
        guard let locationPoint = touches.first?.location(in: textView) else {
            return
        }
        if let item = manager.getWord(locationPoint: locationPoint) {
            detectionBlock?(item.0, item.1)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
}
