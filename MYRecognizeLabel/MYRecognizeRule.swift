//
//  MYRecognizeRule.swift
//  ListenSpeak
//
//  Created by ios on 2025/1/13.
//

import UIKit

protocol MYRecognizeRule {
    
    var pattern: String { get }
}

// 单词识别规则
class MYWordRecognizeRule: MYRecognizeRule {
    
    var pattern: String {
        "[\\w'0-9\\-:]+"
    }
}

// 邮箱识别规则
class MYEmailRecognizeRule: MYRecognizeRule {
    
    var pattern: String {
        "[\\w0-9]+@[\\w0-9]+\\.[\\w0-9]+"
    }
}
