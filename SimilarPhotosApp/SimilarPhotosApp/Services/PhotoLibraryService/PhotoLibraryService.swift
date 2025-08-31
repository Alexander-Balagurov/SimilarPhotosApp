//
//  PhotoLibraryService.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import DependenciesMacros
import Photos
import UIKit

@DependencyClient
struct PhotoLibraryService {
    var fetchPhotoAssets: () async -> [PHAsset] = { [] }
    var fetchImage: (PHAsset) async -> UIImage? = { _ in nil }
}

extension DependencyValues {
    var photoLibraryService: PhotoLibraryService {
        get { self[PhotoLibraryServiceKey.self] }
        set { self[PhotoLibraryServiceKey.self] = newValue }
    }
    
    enum PhotoLibraryServiceKey: TestDependencyKey {
        static let testValue = PhotoLibraryService()
    }
}
