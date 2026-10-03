//
//  LogFoodViewModel.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation
import Observation
import WidgetKit

/// Holds the meal or treat the owner is logging and saves it against the vet's allowance
@Observable
final class LogFoodViewModel {
    var foodName = ""
    var foodType: FoodType = .regularMeal
    var gramsText = ""
    var eatenAt = Date()

    private(set) var errorMessage: String?

    private let dogID: UUID
    private let container: AppContainer

    init(dogID: UUID, container: AppContainer) {
        self.dogID = dogID
        self.container = container
    }

    /// Saves the food entry. Returns true when it was saved.
    func logFood() -> Bool {
        errorMessage = nil

        guard let grams = Int(gramsText) else {
            errorMessage = "Enter the amount in grams as a whole number, for example 150."
            return false
        }

        // A blank name falls back to "Meal" or "Treat" so the log still reads clearly
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmedName.isEmpty ? foodType.displayName : trimmedName

        do {
            _ = try container.logFood.logFood(forDogID: dogID, name: name, type: foodType,
                                              grams: grams, eatenAt: eatenAt)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            errorMessage = error.ownerFacingMessage
            return false
        }
    }
}

extension FoodType {
    /// How each kind of food is named on screen
    var displayName: String {
        switch self {
        case .regularMeal: return "Meal"
        case .treat: return "Treat"
        }
    }
}
