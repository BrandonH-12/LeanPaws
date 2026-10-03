//
//  PlanSetupViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation
import WidgetKit

/// Holds what the owner types in after the vet visit and saves the dog and its plan
@Observable
final class PlanSetupViewModel {
    // Dog details (only needed when there's no dog yet)
    var dogName = ""
    var breed = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()

    // The vet's targets, typed as text and checked when saving
    var startWeightText = ""
    var targetWeightText = ""
    var foodAllowanceText = ""
    var walkTargetText = ""
    var hasVetCheckBooked = false
    var nextVetCheck = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

    private(set) var errorMessage: String?
    let needsDogDetails: Bool

    private let existingDogID: UUID?
    private let container: AppContainer

    init(existingDogID: UUID?, container: AppContainer) {
        self.existingDogID = existingDogID
        self.needsDogDetails = existingDogID == nil
        self.container = container
    }

    /// Saves the dog (if new) and the vet's plan. Returns true when everything was saved.
    func savePlan() -> Bool {
        errorMessage = nil

        // Turn the typed text into numbers, with a friendly message if something isn't a number
        guard let startWeightKg = Double(startWeightText),
              let targetWeightKg = Double(targetWeightText) else {
            errorMessage = "Enter both weights in kilograms, for example 32.5."
            return false
        }
        guard let foodAllowanceGrams = Int(foodAllowanceText),
              let walkTargetMinutes = Int(walkTargetText) else {
            errorMessage = "Enter the food allowance in grams and the walking goal in minutes, as whole numbers."
            return false
        }

        do {
            // Step 1: use the existing dog, or add a new one
            let dogID = try existingDogID
                ?? container.addDog.addDog(name: dogName, breed: breed, dateOfBirth: dateOfBirth).id

            // Step 2: save the vet's plan for that dog
            _ = try container.createPlan.createPlan(
                forDogID: dogID,
                startWeightKg: startWeightKg,
                targetWeightKg: targetWeightKg,
                dailyFoodAllowanceGrams: foodAllowanceGrams,
                dailyWalkTargetMinutes: walkTargetMinutes,
                nextVetCheck: hasVetCheckBooked ? nextVetCheck : nil
            )

            // Let the widget show the new plan straight away
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            errorMessage = error.ownerFacingMessage
            return false
        }
    }
}
