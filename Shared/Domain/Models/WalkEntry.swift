//
//  WalkEntry.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

/// A walk the owner took their dog on, counted toward the vet's daily walking target
struct WalkEntry: Identifiable, Equatable{
    let id: UUID
    let dogID: UUID
    let walkedAt: Date
    let walkDurationMinutes: Int
    
    init(id: UUID = UUID(), dogID: UUID, walkedAt: Date, walkDurationMinutes: Int) {
        self.id = id
        self.dogID = dogID
        self.walkedAt = walkedAt
        self.walkDurationMinutes = walkDurationMinutes
    }
}
