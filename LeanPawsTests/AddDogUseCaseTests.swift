//
//  AddDogUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct AddDogUseCaseTests {

    let dogProfiles = MockDogProfileRepository()
    let useCase: AddDogUseCase

    init() {
        useCase = AddDogUseCase(dogProfileRepository: dogProfiles)
    }

    @Test("A dog with a name is saved")
    func namedDogIsSaved() throws {
        let dog = try useCase.addDog(name: "Max", breed: "Labrador", dateOfBirth: Date())

        #expect(try dogProfiles.fetchAllDogs() == [dog])
    }

    @Test("A name made only of spaces is rejected")
    func blankNameIsRejected() {
        #expect(throws: AddDogError.missingName) {
            try useCase.addDog(name: "   ", breed: "Labrador", dateOfBirth: Date())
        }
    }

    @Test("A date of birth in the future is rejected")
    func futureBirthdayIsRejected() {
        let now = Date()

        #expect(throws: AddDogError.bornInFuture) {
            try useCase.addDog(name: "Max", breed: "Labrador",
                               dateOfBirth: now.addingTimeInterval(24 * 60 * 60), now: now)
        }
    }
}
