//
//  VisionService.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import DependenciesMacros
import Photos
import Vision

@DependencyClient
struct VisionService {
    var clusterPhotos: () async -> [[PHAsset]] = { [[]] }
}

extension DependencyValues {
    var visionService: VisionService {
        get { self[VisionServiceKey.self] }
        set { self[VisionServiceKey.self] = newValue }
    }
    
    enum VisionServiceKey: TestDependencyKey {
        static let testValue = VisionService()
    }
}
