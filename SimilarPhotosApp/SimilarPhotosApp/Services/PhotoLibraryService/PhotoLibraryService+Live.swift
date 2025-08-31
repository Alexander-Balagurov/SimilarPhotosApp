//
//  PhotoLibraryService+Live.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Dependencies
import Photos
import UIKit

extension DependencyValues.PhotoLibraryServiceKey: DependencyKey {
    public static let liveValue = PhotoLibraryService.live()
}

extension PhotoLibraryService {
    static func live() -> PhotoLibraryService {
        let helper = PhotoLibraryHelper()
        return PhotoLibraryService(
            fetchPhotoAssets: helper.fetchPhotoAssets,
        )
    }
    
    private struct PhotoLibraryHelper {
        func fetchPhotoAssets() async throws -> [PhotoModel] {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard status == .authorized || status == .limited else {
                throw CustomError.deniedAccessToLibrary
            }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            var assets: [PHAsset] = []
            fetchResult.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            
            var photos: [PhotoModel] = []
            let asyncPHAssets = AsyncStream<PHAsset> { continuation in
                for asset in assets {
                    continuation.yield(asset)
                }
                continuation.finish()
            }
            
            for await asset in asyncPHAssets {
                let photoModel = try await fetchImage(asset)
                photos.append(photoModel)
            }
            
            return photos
        }
        
        private func fetchImage(_ asset: PHAsset) async throws -> PhotoModel {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
            options.isSynchronous = true
            
            return try await withCheckedThrowingContinuation { continuation in
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: 224, height: 224),
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    guard let photoModel = PhotoModel(id: asset.localIdentifier, image: image) else {
                        continuation.resume(throwing: CustomError.fetchImageError)
                        return
                    }
                    continuation.resume(returning: photoModel)
                }
            }
        }
    }
}
