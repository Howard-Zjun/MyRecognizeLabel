//
//  MYRecognizeLabel.swift
//  ListenSpeak
//
//  Created by Howard-Zjun on 2025/1/9.
//

import UIKit

class MYRecognizeLabel: UILabel {

    var needRecognize: Bool = false {
        didSet {
            isUserInteractionEnabled = needRecognize
        }
    }
    
    var detectionBlock: ((String, NSRange) -> Void)?

    let manager: MYRecognizelManager = .init()
    
    lazy var alpha0Layer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: .init(x: 0, y: 0, width: kwidth, height: 0))
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        return maskLayer
    }()
    
    lazy var baseView: UIView = {
        let baseView = UIView()
        baseView.layer.mask = alpha0Layer
        return baseView
    }()
    
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
        addSubview(baseView)
        baseView.addSubview(textView)
        manager.update(width: kwidth)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(baseView)
        baseView.addSubview(textView)
        manager.update(width: kwidth)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        alpha0Layer.frame = bounds
        baseView.frame = bounds
        textView.frame = baseView.bounds
        manager.update(width: kwidth)
    }
    
    override var text: String? {
        didSet {
            guard let text else { return }
            
            let mText = text.replacingOccurrences(of: "\r", with: "")
            manager.set(text: mText, font: font)
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            guard let attributedText else { return }
            
            let mAttr = NSMutableAttributedString(attributedString: attributedText)
            
            let regex = try! NSRegularExpression(pattern: "\r")
            var location = 0
            for resultItem in regex.matches(in: mAttr.string, range: .init(location: 0, length: mAttr.length)) {
                let range = resultItem.range
                mAttr.replaceCharacters(in: .init(location: location + range.location, length: range.length), with: "")
                location -= range.length
            }
            manager.set(attr: mAttr, font: font)
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
        }
        
        super.touchesEnded(touches, with: event)
    }
}
