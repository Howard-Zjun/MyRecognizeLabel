//
//  DFPickerPhotoManager.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/20.
//

import UIKit
import PhotosUI
import CoreServices

class DFPickerPhotoManager: NSObject {

    var block: ((Any?) -> Void)
    
    init(block: @escaping ((Any?) -> Void)) {
        self.block = block
    }
    
    public func selectPhotoAfterRequestPremission() {
        requestPhotoPermissionWith { [weak self] in
            self?.selectPhoto()
        }
    }
    
    private func selectPhoto() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.filter = .any(of: [.images, .videos])
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .automatic
            // 1. automatic
            // 2. current
            // 3. compatible
            if #available(iOS 15.0, *) {
                config.selection = .default
                // 1. `default`             回调结果不按照点击的顺序，点击添加才有回调
                // 2. ordered               回调结果按照点击的顺序，点击添加才有回调
                // 3. continuous            回调结果不按照点击的顺序，每点一次就有回调
                // 4. continuousAndOrdered  回调结果按照点击的顺序，每点一次就有回调
            }
            if #available(iOS 17.0, *) {
                config.mode = .default
                // 1. default               网格布局
                // 2. compact               线性布局，相当于分页
            }
            let vc = PHPickerViewController(configuration: config)
            vc.title = "选择图片"
            vc.delegate = self
            kKeyWindow?.rootViewController?.present(vc, animated: true)
        } else {
            // 不限制版本但不能多选
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
//            let types = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
            if #available(iOS 14, *) {
                vc.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
            } else {
                vc.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            }
            vc.allowsEditing = false
            vc.delegate = self
            kKeyWindow?.rootViewController?.present(vc, animated: true)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension DFPickerPhotoManager: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 点了取消
        if results.isEmpty {
            picker.dismiss(animated: true)
            return
        }
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, error in
                    var tempImg: UIImage?
                    if let error {
                        print("Error loading image: \(error.localizedDescription)")
                    } else if let img = obj as? UIImage {
                        tempImg = img
                    }
                    
                    DispatchQueue.main.async {
                        self?.block(tempImg)
                        
                        picker.dismiss(animated: true)
                    }
                }
            } else if result.itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
                result.itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] obj, error in
                    var tempImg: PHLivePhoto?
                    if let error {
                        print("Error loading image: \(error.localizedDescription)")
                    } else if let img = obj as? PHLivePhoto {
                        tempImg = img
                    }
                    
                    DispatchQueue.main.async {
                        self?.block(tempImg)
                        
                        picker.dismiss(animated: true)
                    }
                }
            } else {
                // 获取临时文件的URL，回调结束后会被删除
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                    var tempUrl: URL?
                    if let error {
                        print("Error loading video: \(error.localizedDescription)")
                    } else if let url = url {
                        tempUrl = url
                    }
                    
                    DispatchQueue.main.async {
                        self?.block(tempUrl)
                        
                        picker.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DFPickerPhotoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            block(image)
        } else if let image = info[.livePhoto] as? PHLivePhoto {
            block(image)
        } else if let videoURL = info[.mediaURL] as? URL {
            block(videoURL)
        }
        
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

