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
            groupPhotosStream: helper.groupPhotosStream
        )
    }
    
    private struct VisionServiceHelper {
        @Dependency(\.photoLibraryService) private var photoLibraryService
        private let distanceThreshold: Float = 0.6
        private let windowSize = 100
        
        func groupPhotosStream() -> AsyncThrowingStream<ProgressUpdate, Error> {
            AsyncThrowingStream { continuation in
                Task {
                    do {
                        let photos = try await photoLibraryService.fetchPhotoAssets()
                        var result: [[PhotoModel]] = []
                        var used = Set<String>()
                        
                        for (index, photo) in photos.enumerated() {
                            guard !used.contains(photo.id) else { continue }
                            let baseObservation = try await makeObservation(for: photo)
                            var cluster: [PhotoModel] = [photo]
                            used.insert(photo.id)
                            
                            let start = index + 1
                            let end = min(index + windowSize, photos.count)
                            for other in photos[start..<end] {
                                guard !used.contains(other.id) else { continue }
                                let otherObservation = try await makeObservation(for: other)
                                var distance: Float = 0
                                try baseObservation.computeDistance(&distance, to: otherObservation)
                                
                                if distance < distanceThreshold {
                                    cluster.append(other)
                                    used.insert(other.id)
                                }
                            }
                            
                            if cluster.count > 1 {
                                result.append(cluster)
                            }
                            
                            continuation.yield(
                                ProgressUpdate(
                                    clusters: result,
                                    processedCount: used.count,
                                    totalCount: photos.count
                                )
                            )
                        }
                        
                        continuation.finish()
                    } catch {
                        reportIssue(error)
                        continuation.finish(throwing: error)
                    }
                }
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
