//
//  LogWalkViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation
import WidgetKit

/// Holds the walk the owner is logging and saves it toward the vet's walking goal
@Observable
final class LogWalkViewModel {
    var minutesText = ""
    var walkedAt = Date()

    private(set) var errorMessage: String?

    private let dogID: UUID
    private let container: AppContainer

    init(dogID: UUID, container: AppContainer) {
        self.dogID = dogID
        self.container = container
    }

    /// Saves the walk. Returns true when it was saved.
    func logWalk() -> Bool {
        errorMessage = nil

        guard let minutes = Int(minutesText) else {
            errorMessage = "Enter the walk length in minutes as a whole number, for example 30."
            return false
        }

        do {
            _ = try container.logWalk.logWalk(forDogID: dogID, durationMinutes: minutes, walkedAt: walkedAt)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            errorMessage = error.ownerFacingMessage
            return false
        }
    }
}
