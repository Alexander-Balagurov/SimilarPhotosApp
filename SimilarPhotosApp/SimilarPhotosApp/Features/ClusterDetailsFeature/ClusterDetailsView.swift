//
//  ClusterDetailsView.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import ComposableArchitecture
import SwiftUI

struct ClusterDetailsView: View {
    let store: StoreOf<ClusterDetailsFeature>
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(store.photos) { photo in
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
            }
        }
        .navigationTitle("Cluster Details")
    }
}
