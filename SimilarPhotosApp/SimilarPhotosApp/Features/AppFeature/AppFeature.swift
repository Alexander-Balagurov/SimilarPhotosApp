//
//  AppFeature.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 30.08.2025.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var similarPhotos = SimilarPhotosFeature.State()
    }
    
    enum Action {
        case similarPhotos(SimilarPhotosFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.similarPhotos, action: \.similarPhotos) {
            SimilarPhotosFeature()
        }
        
        Reduce { state, action in
                .none
        }
    }
}
