//
//  ProgressUpdate.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import Foundation

struct ProgressUpdate: Equatable {
    let clusters: [[PhotoModel]]
    let processedCount: Int
    let totalCount: Int
}
