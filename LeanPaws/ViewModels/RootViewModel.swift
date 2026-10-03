//
//  RootViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation

/// Decides which screen the owner sees first: plan setup for a new owner, or today's progress
@Observable
final class RootViewModel {
    enum Destination: Equatable {
        case loading
        case planSetup(existingDogID: UUID?)   // a dog may exist without a plan yet
        case today(dogID: UUID)
    }

    private(set) var destination: Destination = .loading
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    // Looks for the owner's dog and its plan, then picks the starting screen
    func refresh() {
        let dog = try? container.dogProfileRepository.fetchAllDogs().first

        guard let dog else {
            destination = .planSetup(existingDogID: nil)
            return
        }

        if (try? container.dogProfileRepository.fetchPlan(forDogID: dog.id)) != nil {
            destination = .today(dogID: dog.id)
        } else {
            destination = .planSetup(existingDogID: dog.id)
        }
    }
}

