//
//  ViewController.swift
//  MYRecognizeLabel
//
//  Created by Howard-Zjun on 2025/1/14.
//

import UIKit
import SnapKit
import MyBaseExtension

class ViewController: UIViewController {

    lazy var wordLab: MYRecognizeLabel = {
        let wordLab = MYRecognizeLabel()
        wordLab.font = .systemFont(ofSize: 24)
        wordLab.textColor = .init(named: "333333")
        wordLab.numberOfLines = 0
        wordLab.text = "Great! I went to many places near my home in India. Great changes have taken place there and my hometown has become more and more beautiful. Where have you been, Jane?"
        wordLab.detectionBlock = { [weak self] text, range in
            self?.wordDetectResultLab.text = text
        }
        wordLab.needRecognize = true
        return wordLab
    }()
    
    lazy var wordDetectResultLab: UILabel = {
        let wordDetectResultLab = UILabel()
        wordDetectResultLab.backgroundColor = .init(hex: 0x888888)
        wordDetectResultLab.textColor = .white
        wordDetectResultLab.textAlignment = .center
        return wordDetectResultLab
    }()
    
    lazy var emailLab: MYRecognizeLabel = {
        let emailLab = MYRecognizeLabel()
        emailLab.manager.rule = MYEmailRecognizeRule()
        emailLab.font = .systemFont(ofSize: 24)
        emailLab.textColor = .init(named: "333333")
        emailLab.numberOfLines = 0
        let text1 = "I'm writing to share my project details. You can find the full report in the attached file. For any queries, reach out to me at "
        let email = "support@example.com"
        let text2 = ". Looking forward to discussing further."
        let attr = NSMutableAttributedString()
        attr.append(.init(string: text1, attributes: [.foregroundColor : UIColor(hex: 333333)]))
        attr.append(.init(string: email, attributes: [.foregroundColor : UIColor.red]))
        attr.append(.init(string: text2, attributes: [.foregroundColor : UIColor(hex: 333333)]))
        emailLab.attributedText = attr
        emailLab.detectionBlock = { [weak self] text, range in
            self?.emailDetectResultLab.text = text
        }
        emailLab.needRecognize = true
        return emailLab
    }()
    
    lazy var emailDetectResultLab: UILabel = {
        let emailDetectResultLab = UILabel()
        emailDetectResultLab.backgroundColor = .init(hex: 0x888888)
        emailDetectResultLab.textColor = .white
        emailDetectResultLab.textAlignment = .center
        return emailDetectResultLab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(wordLab)
        view.addSubview(wordDetectResultLab)
        view.addSubview(emailLab)
        view.addSubview(emailDetectResultLab)
        wordLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(100)
        }
        wordDetectResultLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(wordLab.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        emailLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(wordDetectResultLab.snp.bottom).offset(20)
        }
        emailDetectResultLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(emailLab.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
    }


}

