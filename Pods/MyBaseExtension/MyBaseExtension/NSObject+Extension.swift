//
//  NSObject+Extension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/21.
//

import UIKit

public extension NSObject {
    
    // 创建一个颜色图片
    func createImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let ret = renderer.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
        return ret
    }
}

public extension CALayer {
    
    func createImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let ret = renderer.image { [weak self] context in
            self?.render(in: context.cgContext)
        }
        return ret
    }
}
