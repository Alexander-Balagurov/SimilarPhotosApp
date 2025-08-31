//
//  PhotoModel.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import UIKit

struct PhotoModel: Identifiable, Equatable, Hashable {
    let id: String
    let image: UIImage
    
    init?(id: String, image: UIImage?) {
        guard let image else { return nil }
        self.id = id
        self.image = image
    }
}
