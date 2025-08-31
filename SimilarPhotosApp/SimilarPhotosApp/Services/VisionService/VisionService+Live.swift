//
//  VisionService+Live.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import Vision

extension DependencyValues.VisionServiceKey: DependencyKey {
    public static let liveValue = VisionService.live()
}

extension VisionService {
    static func live() -> VisionService {
        let helper = VisionServiceHelper()
        return VisionService(
            groupPhotos: helper.groupPhotos
        )
    }
    
    private struct VisionServiceHelper {
        @Dependency(\.photoLibraryService) private var photoLibraryService
        private let distanceThreshold: Float = 0.6
        
        func groupPhotos() async throws -> [[PhotoModel]] {
            do {
                let photos = try await photoLibraryService.fetchPhotoAssets()
                var result: [[PhotoModel]] = []
                var used = Set<String>()

                for photo in photos {
                    guard !used.contains(photo.id) else { continue }
                    let baseObservation = try await makeObservation(for: photo)
                    var cluster: [PhotoModel] = [photo]
                    used.insert(photo.id)
                    
                    for other in photos {
                        guard !used.contains(other.id) else { continue }
                        let otherObservation = try await makeObservation(for: other)
                        var distance: Float = 0
                        try baseObservation.computeDistance(&distance, to: otherObservation)
                        print("distance", distance)
                        
                        if distance < distanceThreshold {
                            cluster.append(other)
                            used.insert(other.id)
                        }
                    }
                    if cluster.count > 1 {
                        result.append(cluster)
                    }
                }
                
                return result
            } catch {
                reportIssue(error)
                throw error
            }
        }
        
        private func makeObservation(for photo: PhotoModel) async throws -> VNFeaturePrintObservation {
            guard let cgImage = photo.image.cgImage else { throw CustomError.makeObservationError }
            let request = VNGenerateImageFeaturePrintRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                    throw CustomError.makeObservationError
                }
                return observation
            } catch {
                reportIssue(error)
                throw error
            }
        }
    }
}
