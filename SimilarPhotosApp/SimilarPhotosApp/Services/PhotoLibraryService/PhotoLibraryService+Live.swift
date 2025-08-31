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
            fetchImage: helper.fetchImage
        )
    }
    
    private struct PhotoLibraryHelper {
        func fetchPhotoAssets() async -> [PHAsset] {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard status == .authorized || status == .limited else { return [] }
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(
                format: "mediaType == %d",
                PHAssetMediaType.image.rawValue
            )
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            var assets: [PHAsset] = []
            fetchResult.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            return assets
        }
        
        func fetchImage(_ asset: PHAsset) async -> UIImage? {
            await withCheckedContinuation { continuation in
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: 224, height: 224),
                    contentMode: .aspectFill,
                    options: nil
                ) { image, _ in
                    continuation.resume(returning: image)
                }
            }
        }
    }
}
