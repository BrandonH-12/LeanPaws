//
//  CheckDailyProgressUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import Foundation

/// Problems an owner can hit when checking how their dog is tracking for a day
enum CheckDailyProgressError: Error, Equatable, LocalizedError {
    case dogNotFound
    case noPlanForDog

    var errorDescription: String? {
        switch self {
        case .dogNotFound:
            return "We couldn't find this dog's profile."
        case .noPlanForDog:
            return "Your dog doesn't have a plan from the vet yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dogNotFound:
            return "Go back and add your dog first."
        case .noPlanForDog:
            return "Set up the vet's food and walking targets to start tracking progress."
        }
    }
}

/// Works out how a dog is tracking against the vet's food and walking targets on a given day
struct CheckDailyProgressUseCase {
    let dogProfileRepository: DogProfileRepository
    let activityLogRepository: ActivityLogRepository

    func checkProgress(forDogID dogID: UUID, on day: Date = Date()) throws -> DailyProgress {
        // Rule 1: the dog must exist
        guard let dog = try dogProfileRepository.fetchDog(withID: dogID) else {
            throw CheckDailyProgressError.dogNotFound
        }

        // Rule 2: the dog must have a vet plan to measure against
        guard let plan = try dogProfileRepository.fetchPlan(forDogID: dogID) else {
            throw CheckDailyProgressError.noPlanForDog
        }

        // That day's food and walks for this dog
        let foodEntries = try activityLogRepository.fetchFoodEntries(forDogID: dogID, on: day)
        let walkEntries = try activityLogRepository.fetchWalkEntries(forDogID: dogID, on: day)

        // Rule 3: meals and treats both count toward the daily allowance
        let foodEatenGrams = foodEntries.reduce(0) { total, entry in total + entry.grams }
        let walkedMinutes = walkEntries.reduce(0) { total, entry in total + entry.walkDurationMinutes }

        return DailyProgress(
            dogName: dog.name,
            foodEatenGrams: foodEatenGrams,
            foodAllowanceGrams: plan.dailyFoodAllowanceGrams,
            walkedMinutes: walkedMinutes,
            walkTargetMinutes: plan.dailyWalkTargetMinutes
        )
    }
}
