//
//  MYRecognizelManager.swift
//  ListenSpeak
//
//  Created by Howard-Zjun on 2025/1/13.
//

import UIKit

class MYRecognizelManager: NSObject {

    var ranges: [(word: String, range: NSRange)] = []

    var rule: MYRecognizeRule = MYWordRecognizeRule()
    
    lazy var textStorage: NSTextStorage = {
        let textStorage = NSTextStorage()
        return textStorage
    }()
    
    lazy var layoutManager: NSLayoutManager = {
        let layoutManager = NSLayoutManager()
        return layoutManager
    }()
    
    lazy var textContainer: NSTextContainer = {
        let textContainer = NSTextContainer(size: .init(width: 0, height: CGFLOAT_MAX))
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        return textContainer
    }()
    
    func update(width: CGFloat) {
        textContainer.size = .init(width: width, height: CGFLOAT_MAX)
    }
    
    func set(text: String, font: UIFont) {
        let attr = NSAttributedString(string: text)
        set(attr: attr, font: font)
    }
    
    func set(attr: NSAttributedString, font: UIFont) {
        let attr = NSMutableAttributedString(attributedString: attr)
        attr.addAttribute(.foregroundColor, value: UIColor.clear, range: .init(location: 0, length: attr.length))
        attr.addAttribute(.font, value: font, range: .init(location: 0, length: attr.length))
        let text = attr.string
        var ranges: [(String, NSRange)] = []
        let regex = try! NSRegularExpression(pattern: rule.pattern)
        regex.enumerateMatches(in: text, range: .init(location: 0, length: text.count)) { match, _, _ in
            guard let range = match?.range else { return }
            ranges.append(((text as NSString).substring(with: range), range))
        }
        self.ranges = ranges
        
        textStorage.beginEditing()
        textStorage.setAttributedString(attr)
        textStorage.endEditing()
    }
    
    func charIndex(location: CGPoint) -> Int {
        let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: .init(location: glyphIndex, length: 1), in: textContainer)
        if CGRectContainsPoint(boundingRect, location) {
            return layoutManager.characterIndexForGlyph(at: glyphIndex)
        } else {
            return NSNotFound
        }
    }
    
    func getWord(locationPoint: CGPoint) -> (String, NSRange)? {
        let charIndex = charIndex(location: locationPoint)
        if charIndex != NSNotFound {
            for rangeItem in ranges {
                if charIndex >= rangeItem.range.location && charIndex < rangeItem.range.location + rangeItem.range.length {
                    print("[\(#file)]-[\(#function)]-\(#line) \(rangeItem.word)-\(rangeItem.range)")
                    return rangeItem
                }
            }
        }
        return nil
    }
}
