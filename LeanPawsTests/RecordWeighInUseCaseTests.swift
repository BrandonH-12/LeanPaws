//
//  RecordWeighInUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct RecordWeighInUseCaseTests {

    let dogProfiles = MockDogProfileRepository()
    let weighIns = MockWeighInRepository()
    let max = Dog(name: "Max", breed: "Labrador", dateOfBirth: Date())
    let useCase: RecordWeighInUseCase

    init() throws {
        try dogProfiles.saveDog(max)
        useCase = RecordWeighInUseCase(dogProfileRepository: dogProfiles,
                                       weighInRepository: weighIns)
    }

    @Test("A realistic weigh-in is saved to the dog's weight history")
    func weighInIsSaved() throws {
        let weighIn = try useCase.recordWeighIn(forDogID: max.id, weightKg: 31.4)

        #expect(try weighIns.fetchAllWeighIns(forDogID: max.id) == [weighIn])
    }

    @Test("A second weigh-in on the same day is rejected")
    func secondWeighInSameDayIsRejected() throws {
        _ = try useCase.recordWeighIn(forDogID: max.id, weightKg: 31.4)

        #expect(throws: RecordWeighInError.alreadyWeighedToday) {
            try useCase.recordWeighIn(forDogID: max.id, weightKg: 31.2)
        }
    }

    @Test("Weigh-ins on different days are both saved")
    func weighInsOnDifferentDaysAreSaved() throws {
        let now = Date()
        let yesterday = now.addingTimeInterval(-24 * 60 * 60)

        _ = try useCase.recordWeighIn(forDogID: max.id, weightKg: 31.6,
                                      weighedAt: yesterday, now: now)
        _ = try useCase.recordWeighIn(forDogID: max.id, weightKg: 31.4,
                                      weighedAt: now, now: now)

        #expect(try weighIns.fetchAllWeighIns(forDogID: max.id).count == 2)
    }

    @Test("A weight below what any dog could weigh is rejected")
    func weightBelowPlausibleRangeIsRejected() {
        #expect(throws: RecordWeighInError.implausibleWeight) {
            try useCase.recordWeighIn(forDogID: max.id, weightKg: 0.4)   // just under 0.5
        }
    }

    @Test("The lightest plausible dog weight is accepted")
    func lightestPlausibleWeightIsAccepted() throws {
        let weighIn = try useCase.recordWeighIn(forDogID: max.id, weightKg: 0.5)

        #expect(try weighIns.fetchAllWeighIns(forDogID: max.id) == [weighIn])
    }

    @Test("A weigh-in for a dog that hasn't been added is rejected")
    func weighInForUnknownDogIsRejected() {
        
        #expect(throws: RecordWeighInError.dogNotFound) {
            try useCase.recordWeighIn(forDogID: UUID(), weightKg: 31.4)
        }
    }
}
