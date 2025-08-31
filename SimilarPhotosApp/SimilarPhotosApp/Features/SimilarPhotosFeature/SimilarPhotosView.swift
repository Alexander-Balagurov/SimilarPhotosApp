//
//  SimilarPhotosView.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 30.08.2025.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: SimilarPhotosFeature.self)
struct SimilarPhotosView: View {
    @Bindable var store: StoreOf<SimilarPhotosFeature>
    
    var body: some View {
        NavigationStack {
            NavigationView {
                contentView
                    .navigationTitle("Similar Photos")
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.showClusterDetails,
                    action: \.destination.showClusterDetails
                )
            ) { store in
                ClusterDetailsView(store: store)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch store.screenState {
        case .idle: idleView
        case .processing: ProgressView()
        case let .success(clusters): clustersView(clusters)
        case let .error(error): errorView(error)
        }
    }
    
    private var idleView: some View {
        VStack(spacing: 20) {
            Text("Tap to group photos")
                .font(.headline)
            
            Button("Start") {
                send(.startButtonTapped)
            }
        }
    }
    
    private func clustersView(_ clusters: [PhotoModel]) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                    ForEach(Array(zip(clusters, clusters.indices)), id: \.0) { photo, index in
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .onTapGesture {
                                send(.clusterSelected(index))
                            }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Spacer(minLength: 20)
            
            Text("\(store.progress.processedCount)/\(store.progress.totalCount) processed")
                .font(.caption)
        }
    }
    
    private func errorView(_ error: String) -> some View {
        Text(error)
            .font(.headline)
            .foregroundStyle(.red)
    }
}
