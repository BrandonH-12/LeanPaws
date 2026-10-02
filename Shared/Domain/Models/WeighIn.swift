//
//  WeighIn.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

// Single weight reading for a dog, recorded by an owner on a given day
struct WeighIn: Identifiable, Equatable{
    
    let id: UUID
    let dogID: UUID
    let weighInDate: Date
    let weightKg: Double
    
    init(id: UUID = UUID(), dogID: UUID, weighInDate: Date, weightKg: Double) {
        self.id = id
        self.dogID = dogID
        self.weighInDate = weighInDate
        self.weightKg = weightKg
    }
    
}
