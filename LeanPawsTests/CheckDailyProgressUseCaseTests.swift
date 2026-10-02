//
//  CheckDailyProgressUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct CheckDailyProgressUseCaseTests {

    let dogProfiles = MockDogProfileRepository()
    let activityLog = MockActivityLogRepository()
    let max = Dog(name: "Max", breed: "Labrador", dateOfBirth: Date())
    let useCase: CheckDailyProgressUseCase

    init() throws {
        try dogProfiles.saveDog(max)
        try dogProfiles.savePlan(WeightPlan(
            dogID: max.id, startWeightKg: 32, targetWeightKg: 28,
            dailyFoodAllowanceGrams: 320, dailyWalkTargetMinutes: 40,
            startDate: Date()
        ))
        useCase = CheckDailyProgressUseCase(dogProfileRepository: dogProfiles,
                                            activityLogRepository: activityLog)
    }

    @Test("Meals and treats are added together toward the daily allowance")
    func mealsAndTreatsCountTowardAllowance() throws {
        try activityLog.saveFoodEntry(FoodEntry(dogID: max.id, name: "Dry kibble",
                                                type: .regularMeal, grams: 150, eatenAt: Date()))
        try activityLog.saveFoodEntry(FoodEntry(dogID: max.id, name: "Dental chew",
                                                type: .treat, grams: 20, eatenAt: Date()))

        let progress = try useCase.checkProgress(forDogID: max.id)

        #expect(progress.foodEatenGrams == 170)
        #expect(progress.foodRemainingGrams == 150)
    }

    @Test("Walks are added together toward the daily walking goal")
    func walksCountTowardWalkingGoal() throws {
        try activityLog.saveWalkEntry(WalkEntry(dogID: max.id, walkedAt: Date(), walkDurationMinutes: 25))
        try activityLog.saveWalkEntry(WalkEntry(dogID: max.id, walkedAt: Date(), walkDurationMinutes: 15))

        let progress = try useCase.checkProgress(forDogID: max.id)

        #expect(progress.walkedMinutes == 40)
        #expect(progress.hasMetWalkTarget == true)
    }

    @Test("Eating exactly the daily allowance is not counted as over")
    func eatingExactlyTheAllowanceIsNotOver() throws {
        try activityLog.saveFoodEntry(FoodEntry(dogID: max.id, name: "Dry kibble",
                                                type: .regularMeal, grams: 320, eatenAt: Date()))

        let progress = try useCase.checkProgress(forDogID: max.id)

        #expect(progress.isOverFoodAllowance == false)
    }

    @Test("Eating more than the daily allowance is flagged as over")
    func eatingMoreThanTheAllowanceIsFlagged() throws {
        try activityLog.saveFoodEntry(FoodEntry(dogID: max.id, name: "Dry kibble",
                                                type: .regularMeal, grams: 350, eatenAt: Date()))

        let progress = try useCase.checkProgress(forDogID: max.id)

        #expect(progress.isOverFoodAllowance == true)
        #expect(progress.foodRemainingGrams == 0)
    }

    @Test("Food from yesterday doesn't count toward today")
    func yesterdaysFoodIsNotCounted() throws {
        let yesterday = Date().addingTimeInterval(-24 * 60 * 60)
        try activityLog.saveFoodEntry(FoodEntry(dogID: max.id, name: "Dry kibble",
                                                type: .regularMeal, grams: 150, eatenAt: yesterday))

        let progress = try useCase.checkProgress(forDogID: max.id)

        #expect(progress.foodEatenGrams == 0)
    }

    @Test("Checking progress for a dog without a vet plan is rejected")
    func progressForDogWithoutPlanIsRejected() throws {
        let bella = Dog(name: "Bella", breed: "Beagle", dateOfBirth: Date())
        try dogProfiles.saveDog(bella)

        #expect(throws: CheckDailyProgressError.noPlanForDog) {
            try useCase.checkProgress(forDogID: bella.id)
        }
    }
}
