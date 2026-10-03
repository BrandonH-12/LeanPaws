//
//  RootView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI

/// The app's starting point: shows plan setup or today's progress depending on what's saved
struct RootView: View {
    let container: AppContainer
    @State private var viewModel: RootViewModel

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: RootViewModel(container: container))
    }

    var body: some View {
        Group {
            switch viewModel.destination {
            case .loading:
                ProgressView()
            case .planSetup(let existingDogID):
                PlanSetupView(viewModel: PlanSetupViewModel(existingDogID: existingDogID, container: container), onPlanSaved: {viewModel.refresh()})
            case .today:
                Text("Today goes here")         // replaced by the real screen after that
            }
        }
        .task { viewModel.refresh() }
    }
}
