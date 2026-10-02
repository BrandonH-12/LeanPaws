//
//  LogWalkUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct LogWalkUseCaseTests {

    let dogProfiles = MockDogProfileRepository()
    let activityLog = MockActivityLogRepository()
    let max = Dog(name: "Max", breed: "Labrador", dateOfBirth: Date())
    let useCase: LogWalkUseCase

    init() throws {
        try dogProfiles.saveDog(max)
        try dogProfiles.savePlan(WeightPlan(
            dogID: max.id, startWeightKg: 32, targetWeightKg: 28,
            dailyFoodAllowanceGrams: 320, dailyWalkTargetMinutes: 40,
            startDate: Date()
        ))
        useCase = LogWalkUseCase(dogProfileRepository: dogProfiles,
                                 activityLogRepository: activityLog)
    }

    @Test("A walk for a dog on a vet plan is saved to today's log")
    func walkIsSaved() throws {
        let entry = try useCase.logWalk(forDogID: max.id, durationMinutes: 30)

        #expect(try activityLog.fetchWalkEntries(forDogID: max.id, on: Date()) == [entry])
    }

    @Test("A walk of 0 minutes is rejected")
    func zeroMinuteWalkIsRejected() {
        #expect(throws: LogWalkError.invalidDuration) {
            try useCase.logWalk(forDogID: max.id, durationMinutes: 0)
        }
    }

    @Test("A 1-minute walk is accepted")
    func oneMinuteWalkIsAccepted() throws {
        let entry = try useCase.logWalk(forDogID: max.id, durationMinutes: 1)

        #expect(try activityLog.fetchWalkEntries(forDogID: max.id, on: Date()) == [entry])
    }

    @Test("A walk for a dog without a vet plan is rejected")
    func walkForDogWithoutPlanIsRejected() throws {
        let bella = Dog(name: "Bella", breed: "Beagle", dateOfBirth: Date())
        try dogProfiles.saveDog(bella)

        #expect(throws: LogWalkError.noPlanForDog) {
            try useCase.logWalk(forDogID: bella.id, durationMinutes: 30)
        }
    }

    @Test("A walk logged one minute in the future is rejected")
    func walkInFutureIsRejected() {
        let now = Date()

        #expect(throws: LogWalkError.walkedInFuture) {
            try useCase.logWalk(forDogID: max.id, durationMinutes: 30,
                                walkedAt: now.addingTimeInterval(60) , now: now)
        }
    }
}
