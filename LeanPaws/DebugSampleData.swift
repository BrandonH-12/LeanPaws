//
//  DebugSampleData.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import Foundation

#if DEBUG
/// Fills an empty database with one example dog so the widget can be tested before the screens exist.
/// Note: Debug builds only remove before submission
enum DebugSampleData {
    static func addIfEmpty() {
        let dogProfiles = CoreDataDogProfileRepository()
        let activityLog = CoreDataActivityLogRepository()

        do {
            // Only add sample data the very first time
            guard try dogProfiles.fetchAllDogs().isEmpty else { return }

            let max = Dog(name: "Max", breed: "Labrador",
                          dateOfBirth: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date())
            try dogProfiles.saveDog(max)

            _ = try CreatePlanUseCase(dogProfileRepository: dogProfiles)
                .createPlan(forDogID: max.id, startWeightKg: 32, targetWeightKg: 28,
                            dailyFoodAllowanceGrams: 320, dailyWalkTargetMinutes: 40)

            let logFood = LogFoodUseCase(dogProfileRepository: dogProfiles, activityLogRepository: activityLog)
            _ = try logFood.logFood(forDogID: max.id, name: "Dry kibble", type: .regularMeal, grams: 150)
            _ = try logFood.logFood(forDogID: max.id, name: "Dental chew", type: .treat, grams: 20)

            _ = try LogWalkUseCase(dogProfileRepository: dogProfiles, activityLogRepository: activityLog)
                .logWalk(forDogID: max.id, durationMinutes: 25)
        } catch {
            print("Couldn't add sample data: \(error)")
        }
    }
}
#endif
