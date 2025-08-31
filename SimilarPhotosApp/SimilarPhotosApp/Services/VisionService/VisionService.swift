//
//  VisionService.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import DependenciesMacros
import Vision

@DependencyClient
struct VisionService {
    var groupPhotosStream: () -> AsyncThrowingStream<ProgressUpdate, Error> = { .never }
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
