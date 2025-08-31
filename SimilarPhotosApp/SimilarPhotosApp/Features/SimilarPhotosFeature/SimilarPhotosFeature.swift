//
//  SimilarPhotosFeature.swift
//  SimilarPhotosApp
//
//  Created by Oleksandr Balahurov on 30.08.2025.
//

import ComposableArchitecture

@Reducer
struct SimilarPhotosFeature {
    @ObservableState
    struct State: Equatable {
        enum ScreenState: Equatable {
            case idle
            case processing
            case success
            case error(String)
        }
        
        var screenState: ScreenState = .idle
    }
    
    enum Action: Equatable, ViewAction {
        enum View: Equatable {
            case onAppear
            case startButtonTapped
            case clusterSelected(Int)
        }
        
        case view(View)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return .none
            }
        }
    }
}
