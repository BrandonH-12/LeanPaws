//
//  LogFoodUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct LogFoodUseCaseTests {

    let dogProfiles = MockDogProfileRepository()
    let activityLog = MockActivityLogRepository()
    let max = Dog(name: "Max", breed: "Labrador", dateOfBirth: Date())
    let useCase: LogFoodUseCase

    init() throws {
        try dogProfiles.saveDog(max)
        try dogProfiles.savePlan(WeightPlan(
            dogID: max.id, startWeightKg: 32, targetWeightKg: 28,
            dailyFoodAllowanceGrams: 320, dailyWalkTargetMinutes: 40,
            startDate: Date()
        ))
        useCase = LogFoodUseCase(dogProfileRepository: dogProfiles,
                                 activityLogRepository: activityLog)
    }

    @Test("A meal for a dog on a vet plan is saved to today's log")
    func mealIsSaved() throws {
        let entry = try useCase.logFood(forDogID: max.id, name: "Dry kibble",
                                        type: .regularMeal, grams: 150)

        #expect(try activityLog.fetchFoodEntries(forDogID: max.id, on: Date()) == [entry])
    }
    
    @Test("A treat is saved and counts as food for the day")
    func treatIsSaved() throws {
        let entry = try useCase.logFood(forDogID: max.id, name: "Dental chew",
                                        type: .treat, grams: 20)

        #expect(try activityLog.fetchFoodEntries(forDogID: max.id, on: Date()) == [entry])
    }

    @Test("Logging 0 grams of food is rejected")
    func zeroGramsIsRejected() {
        #expect(throws: LogFoodError.invalidAmount) {
            try useCase.logFood(forDogID: max.id, name: "Dry kibble",
                                type: .regularMeal, grams: 0)
        }
    }

    @Test("Food for a dog without a vet plan is rejected")
    func foodForDogWithoutPlanIsRejected() throws {
        let bella = Dog(name: "Bella", breed: "Beagle", dateOfBirth: Date())
        try dogProfiles.saveDog(bella)   // saved, but no plan

        #expect(throws: LogFoodError.noPlanForDog) {
            try useCase.logFood(forDogID: bella.id, name: "Dry kibble",
                                type: .regularMeal, grams: 150)
        }
    }

    @Test("Food logged one minute in the future is rejected")
    func foodInFutureIsRejected() {
        let now = Date()

        #expect(throws: LogFoodError.eatenInFuture) {
            try useCase.logFood(forDogID: max.id, name: "Dry kibble",
                                type: .regularMeal, grams: 150,
                                eatenAt: now.addingTimeInterval(60), now: now)
        }
    }

    @Test("Food eaten at exactly the current time is accepted")
    func foodEatenNowIsAccepted() throws {
        let now = Date()

        let entry = try useCase.logFood(forDogID: max.id, name: "Dry kibble",
                                        type: .regularMeal, grams: 150,
                                        eatenAt: now, now: now)

        #expect(try activityLog.fetchFoodEntries(forDogID: max.id, on: now) == [entry])
    }
}
