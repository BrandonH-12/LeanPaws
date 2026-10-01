//
//  FoodEntry.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

enum FoodType: String,Equatable, CaseIterable{
    case regularMeal
    case treat
}

///Food owner gave to their dogs. Meals and treats both count towards daily allowance 
struct FoodEntry: Identifiable, Equatable {
    let id: UUID
    let dogID: UUID
    let name: String
    let type: FoodType
    let grams: Int
    let eatenAt: Date
    
    init(id: UUID = UUID(), dogID: UUID, name: String, type: FoodType, grams: Int, eatenAt: Date) {
        self.id = id
        self.dogID = dogID
        self.name = name
        self.type = type
        self.grams = grams
        self.eatenAt = eatenAt
    }
}
