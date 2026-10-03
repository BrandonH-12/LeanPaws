//
//  WeightProgressViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation

/// Loads the dog's weight history and records new weigh-ins
@Observable
final class WeightProgressViewModel {
    var weightText = ""

    private(set) var weighIns: [WeighIn] = []
    private(set) var startWeightKg: Double?
    private(set) var targetWeightKg: Double?
    private(set) var errorMessage: String?
    private(set) var confirmationMessage: String?

    private let dogID: UUID
    private let container: AppContainer

    init(dogID: UUID, container: AppContainer) {
        self.dogID = dogID
        self.container = container
    }

    /// The most recent weigh-in, or the plan's starting weight if there are none yet
    var currentWeightKg: Double? {
        weighIns.last?.weightKg ?? startWeightKg
    }

    /// How many kilograms are left to reach the vet's goal (never below zero)
    var kilogramsToGo: Double? {
        guard let current = currentWeightKg, let target = targetWeightKg else { return nil }
        return max(0, current - target)
    }

    // Reads the weight history and the vet's goal
    func loadWeightHistory() {
        do {
            weighIns = try container.weighInRepository.fetchAllWeighIns(forDogID: dogID)
            let plan = try container.dogProfileRepository.fetchPlan(forDogID: dogID)
            startWeightKg = plan?.startWeightKg
            targetWeightKg = plan?.targetWeightKg
        } catch {
            errorMessage = error.ownerFacingMessage
        }
    }

    // Saves today's weight through the use case, which enforces one weigh-in per day
    func recordWeighIn() {
        errorMessage = nil
        confirmationMessage = nil

        guard let weightKg = Double(weightText) else {
            errorMessage = "Enter the weight in kilograms, for example 31.4."
            return
        }

        do {
            _ = try container.recordWeighIn.recordWeighIn(forDogID: dogID, weightKg: weightKg)
            weightText = ""
            confirmationMessage = "Weigh-in saved."
            loadWeightHistory()
        } catch {
            errorMessage = error.ownerFacingMessage
        }
    }
}
