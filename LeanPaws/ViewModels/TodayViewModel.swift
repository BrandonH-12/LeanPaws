//
//  TodayViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation

/// Loads how the dog is tracking against the vet's targets today
@Observable
final class TodayViewModel {
    private(set) var progress: DailyProgress?
    private(set) var errorMessage: String?

    let dogID: UUID
    let container: AppContainer

    init(dogID: UUID, container: AppContainer) {
        self.dogID = dogID
        self.container = container
    }

    // Called when the screen appears, and again when the owner comes back from logging something
    func loadTodaysProgress() {
        do {
            progress = try container.checkDailyProgress.checkProgress(forDogID: dogID)
            errorMessage = nil
        } catch {
            progress = nil
            errorMessage = error.ownerFacingMessage
        }
    }
    
    // Asks for notification permission once the owner has a plan, then schedules the evening check-in
    func setUpEveningCheckIn() async {
        guard let dogName = progress?.dogName else { return }
        await CheckInNotifications.requestPermissionAndSchedule(dogName: dogName)
    }
}
