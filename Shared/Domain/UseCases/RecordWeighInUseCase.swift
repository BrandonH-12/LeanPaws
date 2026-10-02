//
//  RecordWeighInUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import Foundation

/// Problems an owner can hit when recording their dog's weight
enum RecordWeighInError: Error, Equatable, LocalizedError {
    case dogNotFound
    case implausibleWeight
    case alreadyWeighedToday
    case weighedInFuture

    var errorDescription: String? {
        switch self {
        case .dogNotFound:
            return "We couldn't find this dog's profile."
        case .implausibleWeight:
            return "That weight doesn't look right for a dog."
        case .alreadyWeighedToday:
            return "Your dog has already been weighed today."
        case .weighedInFuture:
            return "This weigh-in is set for a time that hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .dogNotFound:
            return "Go back and add your dog first."
        case .implausibleWeight:
            return "Check the scale reading and enter it in kilograms, e.g. 24.5."
        case .alreadyWeighedToday:
            return "Weigh again tomorrow — one reading a day keeps the trend accurate for your vet."
        case .weighedInFuture:
            return "Check the date and record it once your dog has been weighed."
        }
    }
}

/// Records a dog's weight so the owner and vet can track progress toward the goal
struct RecordWeighInUseCase {
    let dogProfileRepository: DogProfileRepository
    let weighInRepository: WeighInRepository

    // The lightest and heaviest weights a real dog could plausibly be
    static let plausibleWeightRangeKg = 0.5...120.0

    func recordWeighIn(
        forDogID dogID: UUID,
        weightKg: Double,
        weighedAt: Date = Date(),
        now: Date = Date()
    ) throws -> WeighIn {
        // Rule 1: the dog must exist
        guard try dogProfileRepository.fetchDog(withID: dogID) != nil else {
            throw RecordWeighInError.dogNotFound
        }

        // Rule 2: the weight must be within the plausible range
        guard Self.plausibleWeightRangeKg.contains(weightKg) else {
            throw RecordWeighInError.implausibleWeight
        }

        // Rule 3: can't be weighed in the future
        guard weighedAt <= now else {
            throw RecordWeighInError.weighedInFuture
        }

        // Rule 4: only one weigh-in per day
        guard try weighInRepository.fetchWeighIn(forDogID: dogID, on: weighedAt) == nil else {
            throw RecordWeighInError.alreadyWeighedToday
        }
    

        let weighIn = WeighIn(dogID: dogID, weighInDate: weighedAt, weightKg: weightKg)
        try weighInRepository.saveWeighIn(weighIn)
        return weighIn
    }
}
