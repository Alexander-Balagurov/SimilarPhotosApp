//
//  CustomError.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Foundation

enum CustomError: LocalizedError {
    case deniedAccessToLibrary
    case makeObservationError
    case fetchImageError
    
    var errorDescription: String? {
        switch self {
        case .deniedAccessToLibrary: "Denied access to library"
        case .makeObservationError: "Make observation error"
        case .fetchImageError: "Fetch image error"
        }
    }
}
