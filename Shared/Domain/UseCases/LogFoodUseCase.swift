//
//  LogFoodUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

/// Problems an owner can hit when logging a meal or treat
enum LogFoodError: Error, Equatable, LocalizedError {
    case noPlanForDog
    case invalidAmount
    case eatenInFuture

    var errorDescription: String? {
        switch self {
        case .noPlanForDog:
            return "Your dog doesn't have a plan from the vet yet."
        case .invalidAmount:
            return "The amount needs to be more than 0 grams."
        case .eatenInFuture:
            return "This meal is set for a time that hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noPlanForDog:
            return "Set up the vet's food and walking targets before logging food."
        case .invalidAmount:
            return "Weigh or estimate the food and enter it in grams."
        case .eatenInFuture:
            return "Check the time and log it once your dog has eaten."
        }
    }
}

/// Records a meal or treat the owner gave their dog, counted toward the vet's daily allowance
struct LogFoodUseCase {
    let dogProfileRepository: DogProfileRepository
    let activityLogRepository: ActivityLogRepository

    func logFood(
        forDogID dogID: UUID,
        name: String,
        type: FoodType,
        grams: Int,
        eatenAt: Date = Date(),
        now: Date = Date()
    ) throws -> FoodEntry {
        // Rule 1: the dog must have a vet plan to log against
        guard try dogProfileRepository.fetchPlan(forDogID: dogID) != nil else {
            throw LogFoodError.noPlanForDog
        }

        // Rule 2: the amount must be more than zero
        guard grams > 0 else {
            throw LogFoodError.invalidAmount
        }

        // Rule 3: food can't be logged for a time that hasn't happened yet
        guard eatenAt <= now else {
            throw LogFoodError.eatenInFuture
        }

        let entry = FoodEntry(dogID: dogID, name: name, type: type, grams: grams, eatenAt: eatenAt)
        try activityLogRepository.saveFoodEntry(entry)
        return entry
    }
}
