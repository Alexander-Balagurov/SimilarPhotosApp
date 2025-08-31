//
//  ClusterDetailsFeature.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 31.08.2025.
//

import ComposableArchitecture

@Reducer
struct ClusterDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let photos: [PhotoModel]
    }
    
    enum Action: Equatable {}
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
