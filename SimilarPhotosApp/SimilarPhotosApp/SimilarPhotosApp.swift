//
//  SimilarPhotosAppApp.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 30.08.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct SimilarPhotosApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: SimilarPhotosApp.store)
        }
    }
}
