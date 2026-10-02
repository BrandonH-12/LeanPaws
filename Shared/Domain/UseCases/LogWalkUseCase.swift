//
//  LogWalkUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

/// Problems an owner can hit when logging a walk
enum LogWalkError: Error, Equatable, LocalizedError {
    case noPlanForDog
    case invalidDuration
    case walkedInFuture

    var errorDescription: String? {
        switch self {
        case .noPlanForDog:
            return "Your dog doesn't have a plan from the vet yet."
        case .invalidDuration:
            return "The walk needs to be at least 1 minute long."
        case .walkedInFuture:
            return "This walk is set for a time that hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noPlanForDog:
            return "Set up the vet's food and walking targets before logging walks."
        case .invalidDuration:
            return "Enter roughly how many minutes you walked your dog."
        case .walkedInFuture:
            return "Check the time and log it once you're back from the walk."
        }
    }
}

/// Records a walk the owner took their dog on, counted toward the vet's daily walking goal
struct LogWalkUseCase {
    let dogProfileRepository: DogProfileRepository
    let activityLogRepository: ActivityLogRepository

    func logWalk(
        forDogID dogID: UUID,
        durationMinutes: Int,
        walkedAt: Date = Date(),
        now: Date = Date()
    ) throws -> WalkEntry {
        // Rule 1: the dog must have a vet plan to log against
        guard try dogProfileRepository.fetchPlan(forDogID: dogID) != nil else{
            throw LogWalkError.noPlanForDog
        }

        // Rule 2: the walk must be at least 1 minute
        guard durationMinutes >= 1 else {
            throw LogWalkError.invalidDuration
        }

        // Rule 3: a walk can't be logged for a time that hasn't happened yet
        guard walkedAt <= now else {
            throw LogWalkError.walkedInFuture
        }

        let entry = WalkEntry(dogID: dogID, walkedAt: walkedAt, walkDurationMinutes: durationMinutes)
        try activityLogRepository.saveWalkEntry(entry)
        return entry
    }
}
