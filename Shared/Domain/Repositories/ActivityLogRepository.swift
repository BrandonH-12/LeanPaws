//
//  ActivityLogRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation
/// Records the food and walks an owner logs for their dog, and reads back a given day's entries
protocol ActivityLogRepository {
    func saveFoodEntry(_ foodEntry: FoodEntry) throws
    func fetchFoodEntries(forDogID dogID: UUID, on day: Date) throws -> [FoodEntry]
    
    func saveWalkEntry(_ walkEntry: WalkEntry) throws
    func fetchWalkEntries(forDogID dogID: UUID, on day: Date) throws -> [WalkEntry]
}
