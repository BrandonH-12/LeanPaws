//
//  Dog.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

struct Dog: Identifiable, Equatable {
    
    let id: UUID
    var name: String
    var breed: String
    var dateOfBirth: Date
    
    init(id: UUID = UUID(), name: String, breed: String, dateOfBirth: Date){
        self.id = id
        self.name = name
        self.breed = breed
        self.dateOfBirth = dateOfBirth
    }
}
