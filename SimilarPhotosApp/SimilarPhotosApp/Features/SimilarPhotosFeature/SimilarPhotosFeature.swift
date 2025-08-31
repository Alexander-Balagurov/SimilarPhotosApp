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
            case success([PhotoModel])
            case error(String)
        }
        
        var screenState: ScreenState = .idle
        var clusters: [[PhotoModel]] = []
        @Presents var destination: Destination.State?
    }
    
    enum Action: ViewAction {
        enum View {
            case startButtonTapped
            case clusterSelected(Int)
        }
        
        enum Local {
            case photosGrouped([[PhotoModel]])
            case processingError(String)
        }

        case view(View)
        case local(Local)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case showClusterDetails(ClusterDetailsFeature)
    }
    
    @Dependency(\.visionService) private var visionService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return handleView(state: &state, action: action)
            
            case let .local(action):
                return handleLocal(state: &state, action: action)
            
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

private extension SimilarPhotosFeature {
    func handleView(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .startButtonTapped:
            state.screenState = .processing
            return .run { send in
                do {
                    let clusters = try await visionService.groupPhotos()
                    await send(.local(.photosGrouped(clusters)))
                } catch {
                    await send(.local(.processingError(error.localizedDescription)))
                }
            }
            
        case let .clusterSelected(index):
            let clusterDetailsState = ClusterDetailsFeature.State(photos: state.clusters[index])
            state.destination = .showClusterDetails(clusterDetailsState)
            return .none
        }
    }
    
    func handleLocal(state: inout State, action: Action.Local) -> Effect<Action> {
        switch action {
        case let .photosGrouped(clusters):
            state.clusters = clusters
            state.screenState = .success(clusters.compactMap(\.first))
            return .none
            
        case let .processingError(error):
            state.screenState = .error(error)
            return .none
        }
    }
}
