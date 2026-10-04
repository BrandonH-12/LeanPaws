//
//  AddDogUseCase.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation

/// Problems an owner can hit when adding their dog
enum AddDogError: Error, Equatable, LocalizedError {
    case missingName
    case bornInFuture

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Your dog needs a name."
        case .bornInFuture:
            return "That date of birth hasn't happened yet."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingName:
            return "Enter the name you call your dog, like \"Max\"."
        case .bornInFuture:
            return "Check the date. If you're not sure, an approximate birthday is fine."
        }
    }
}

/// Adds the owner's dog so a vet plan can be set up for it
struct AddDogUseCase {
    let dogProfileRepository: DogProfileRepository

    func addDog(name: String, breed: String, dateOfBirth: Date, now: Date = Date()) throws -> Dog {
        // Ignore spaces around the name, so "  Max " is saved as "Max"
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Rule 1: the dog must have a name
        guard !trimmedName.isEmpty else {
            throw AddDogError.missingName
        }

        // Rule 2: the date of birth can't be in the future
        guard dateOfBirth <= now else {
            throw AddDogError.bornInFuture
        }

        let dog = Dog(name: trimmedName, breed: breed, dateOfBirth: dateOfBirth)
        try dogProfileRepository.saveDog(dog)
        return dog
    }
}
