//
//  PhotoLibraryService.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct PhotoLibraryService {
    var fetchPhotoAssets: () async throws -> [PhotoModel]
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
