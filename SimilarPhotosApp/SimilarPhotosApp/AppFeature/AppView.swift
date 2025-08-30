//
//  AppView.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 30.08.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            SimilarPhotosView(
                store: store.scope(
                    state: \.similarPhotos,
                    action: \.similarPhotos
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: .similarPhotosImageName)
                    Text(verbatim: .similarPhotosTab)
                }
            }
        }
    }
    
}

private extension String {
    static let similarPhotosTab = "Similar Photos"
    static let similarPhotosImageName = "photo.stack"
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
