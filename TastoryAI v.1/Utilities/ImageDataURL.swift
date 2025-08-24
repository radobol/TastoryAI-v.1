//
//  ImageDataURL.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/24/25.
//

import UIKit

struct ImageDataURL {
    static func create(from image: UIImage, compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }
}