//
//  StringExtension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/20.
//

import UIKit

public extension String {
    
    // MARK: -
    /// 是不是数字
    var isNumber: Bool {
        components(separatedBy: .decimalDigits.inverted).joined() == self
    }
    
    /// 是不是字母
    var isLetters: Bool {
        components(separatedBy: .letters.inverted).joined() == self
    }
    
    /// 是不是数字和字母
    var isNumberAndLetters: Bool {
        components(separatedBy: .decimalDigits.union(.letters).inverted).joined() == self
    }
    
    // MARK: - 剪切
    func textHeight(textWidth: CGFloat, font: UIFont) -> CGFloat {
        (self as NSString).boundingRect(with: .init(width: textWidth, height: CGFLOAT_MAX), attributes: [.font : font], context: nil).size.height
    }
    
    /// 子字符串位置
    func indexOf(_ substring: String) -> Int {
        return indexOf(substring, fromIndex: 0)
    }
    
    /// 子字符串位置
    func indexOf(_ substring: String, fromIndex: Int = 0) -> Int {
        if let range = range(of: substring, options: .literal, range: self.index(self.startIndex, offsetBy: fromIndex)..<self.endIndex) {
            return distance(from: self.startIndex, to: range.lowerBound)
        }
        return NSNotFound
    }
    
    /// 字符串剪切
    func substring(startOffset: Int, length: Int) -> String {
        if startOffset >= count {
            fatalError("startOffset:(\(startOffset)) 不能大于等于 count:(\(count))")
        } else if startOffset < 0 {
            fatalError("startOffset:(\(startOffset)) 不能小于0")
        } else if length <= 0 {
            fatalError("length:(\(length)) 不能小于等于0")
        }
        
        if startOffset + length >= count {
            return String(self[self.index(self.startIndex, offsetBy: startOffset)..<self.endIndex])
        } else {
            return String(self[self.index(self.startIndex, offsetBy: startOffset)..<self.index(self.startIndex, offsetBy: startOffset + length)])
        }
    }
    
    /// 字符串剪切
    func substring(startOffset: Int, endOffset: Int) -> String {
        if endOffset < startOffset {
            fatalError("endOffset:(\(endOffset)) 不能小于 startOffset:(\(startOffset))")
        } else if startOffset < 0 {
            fatalError("startOffset:(\(startOffset)) 不能小于0")
        } else if endOffset >= count {
            fatalError("endOffset:(\(endOffset)) 不能大于等于 count:(\(count))")
        }
        
        return String(self[self.index(self.startIndex, offsetBy: startOffset)...self.index(self.startIndex, offsetBy: endOffset)])
    }
    
    // MARK: - 解析
    func resolverToDict() -> [String : Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json as? [String : Any]
        } catch {
            print("\(#function) error: \(error)")
        }
        return nil
    }
    
    func resolverToArr() -> [[String: Any]]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json as? [[String : Any]]
        } catch {
            print("\(#function) error: \(error)")
        }
        return nil
    }
}
