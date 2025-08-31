//
//  VisionService+Live.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import Photos
import Vision

extension DependencyValues.VisionServiceKey: DependencyKey {
    public static let liveValue = VisionService.live()
}

extension VisionService {
    static func live() -> VisionService {
        let helper = VisionServiceHelper()
        return VisionService(
            clusterPhotos: helper.clusterPhotos
        )
    }
    
    private struct VisionServiceHelper {
        @Dependency(\.photoLibraryService) private var photoLibraryService
        private let distanceThreshold: Float = 0.6
        
        func clusterPhotos() async -> [[PHAsset]] {
            let assets = await photoLibraryService.fetchPhotoAssets()
            var result: [[PHAsset]] = []
            var used = Set<String>()

            for asset in assets {
                guard !used.contains(asset.localIdentifier) else { continue }

                if let baseObservation = await makeObservation(for: asset) {
                    var cluster: [PHAsset] = [asset]
                    used.insert(asset.localIdentifier)

                    for other in assets {
                        guard !used.contains(other.localIdentifier),
                              let otherObservation = await makeObservation(for: other)
                        else { continue }
                        
                        var distance: Float = 0
                        try? baseObservation.computeDistance(&distance, to: otherObservation)
                        print("distance", distance)

                        if distance < distanceThreshold {
                            cluster.append(other)
                            used.insert(other.localIdentifier)
                        }
                    }
                    if cluster.count > 1 {
                        result.append(cluster)
                    }
                }
            }

            print("----", result.count)
            return result
        }
        
        private func makeObservation(for asset: PHAsset) async -> VNFeaturePrintObservation? {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
            options.isSynchronous = false
            
            let image = await photoLibraryService.fetchImage(asset)
            guard let cgImage = image?.cgImage else { return nil }
            
            let request = VNGenerateImageFeaturePrintRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                return request.results?.first as? VNFeaturePrintObservation
            } catch {
                reportIssue(error)
                return nil
            }
        }
    }
}
