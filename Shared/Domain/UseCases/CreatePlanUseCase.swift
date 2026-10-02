//
//  CreatePlanUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

/// Problems an owner can hit when setting up their vet's weight plan
enum CreatePlanError: Error, Equatable, LocalizedError {
    case dogNotFound
    case targetNotBelowStartWeight
    case invalidFoodAllowance
    case invalidWalkTarget

    // What went wrong, in the owner's words
    var errorDescription: String? {
        switch self {
        case .dogNotFound:
            return "We couldn't find this dog's profile."
        case .targetNotBelowStartWeight:
            return "The goal weight needs to be lower than your dog's current weight."
        case .invalidFoodAllowance:
            return "The daily food allowance needs to be more than 0 grams."
        case .invalidWalkTarget:
            return "The daily walking goal needs to be at least 1 minute."
        }
    }

    // What the owner can do next
    var recoverySuggestion: String? {
        switch self {
        case .dogNotFound:
            return "Go back and add your dog first."
        case .targetNotBelowStartWeight:
            return "Check the goal weight your vet gave you and try again."
        case .invalidFoodAllowance:
            return "Enter the daily amount your vet recommended, including treats."
        case .invalidWalkTarget:
            return "Enter how many minutes of walking your vet recommended each day."
        }
    }
}

/// Sets up the diet and exercise targets the vet recommended for a dog
struct CreatePlanUseCase {
    let dogProfileRepository: DogProfileRepository

    func createPlan(
        forDogID dogID: UUID,
        startWeightKg: Double,
        targetWeightKg: Double,
        dailyFoodAllowanceGrams: Int,
        dailyWalkTargetMinutes: Int,
        nextVetCheck: Date? = nil,
        startDate: Date = Date()
    ) throws -> WeightPlan {
        // Rule 1: the dog must exist
        guard try dogProfileRepository.fetchDog(withID: dogID) != nil else {
            throw CreatePlanError.dogNotFound
        }

        // Rule 2: a weight-loss target must be below the starting weight
        guard targetWeightKg < startWeightKg else {
            throw CreatePlanError.targetNotBelowStartWeight
        }

        // Rule 3: the food allowance must be more than zero
        guard dailyFoodAllowanceGrams > 0 else {
            throw CreatePlanError.invalidFoodAllowance
        }

        // Rule 4: the walk target must be more than zero
        guard dailyWalkTargetMinutes > 0 else {
            throw CreatePlanError.invalidWalkTarget
        }

        // All rules passed — build the plan, save it, and hand it back
        let plan = WeightPlan(dogID: dogID, startWeightKg: startWeightKg, targetWeightKg: targetWeightKg, dailyFoodAllowanceGrams: dailyFoodAllowanceGrams, dailyWalkTargetMinutes: dailyWalkTargetMinutes, startDate: startDate, nextVetCheck: nextVetCheck)
        try dogProfileRepository.savePlan(plan)
        return plan
    }
}
