//
//  DailyProgress.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

///Today's snapshot of how dog is tracking against recommended diet and walk target
struct DailyProgress: Equatable{
    let dogName: String
    let foodEatenGrams: Int
    let foodAllowanceGrams: Int
    let walkedMinutes: Int
    let walkTargetMinutes: Int
    
    //Derived answers calculated not stored to display on screen
    var foodRemainingGrams: Int {
        return max(0, foodAllowanceGrams - foodEatenGrams)
    }
    
    var isOverFoodAllowance: Bool {
        return foodEatenGrams > foodAllowanceGrams
    }
    
    var hasMetWalkTarget: Bool {
        return walkedMinutes >= walkTargetMinutes
    }
}
