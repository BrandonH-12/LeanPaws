//
//  WeightPlan.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

struct WeightPlan: Identifiable, Equatable {
    let id: UUID
    
    ///links plan to the dog it belongs to
    let dogID: UUID
    var startWeightKg: Double
    var targetWeightKg: Double
    
    ///set by the vet --> includes treats
    var dailyFoodAllowanceGrams: Int
    var dailyWalkTargetMinutes: Int
    var startDate: Date
    
    var nextVetCheck: Date?
    
    init(id: UUID = UUID(), dogID: UUID, startWeightKg: Double, targetWeightKg: Double, dailyFoodAllowanceGrams: Int, dailyWalkTargetMinutes: Int, startDate: Date, nextVetCheck: Date? = nil) {
        self.id = id
        self.dogID = dogID
        self.startWeightKg = startWeightKg
        self.targetWeightKg = targetWeightKg
        self.dailyFoodAllowanceGrams = dailyFoodAllowanceGrams
        self.dailyWalkTargetMinutes = dailyWalkTargetMinutes
        self.startDate = startDate
        self.nextVetCheck = nextVetCheck
    }
    
}
