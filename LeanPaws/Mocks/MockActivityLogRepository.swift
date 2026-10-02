//
//  MockActivityLogRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

///An in-memory stand-in for the real database's food and walk logs
class MockActivityLogRepository: ActivityLogRepository {
    
    var savedFoodEntries: [FoodEntry] = []
    var savedWalkEntries: [WalkEntry] = []
    
    func saveFoodEntry(_ foodEntry: FoodEntry) throws {
        savedFoodEntries.append(foodEntry)
    }
    
    func fetchFoodEntries(forDogID dogID: UUID, on day: Date) throws -> [FoodEntry] {
        savedFoodEntries.filter {entry in entry.dogID == dogID && Calendar.current.isDate(entry.eatenAt, inSameDayAs: day)}
    }
    
    func saveWalkEntry(_ walkEntry: WalkEntry) throws {
        savedWalkEntries.append(walkEntry)
    }
    
    func fetchWalkEntries(forDogID dogID: UUID, on day: Date) throws -> [WalkEntry] {
        savedWalkEntries.filter {entry in entry.dogID == dogID && Calendar.current.isDate(entry.walkedAt, inSameDayAs: day)}
    }
}
