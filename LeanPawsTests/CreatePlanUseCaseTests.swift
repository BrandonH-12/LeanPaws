//
//  CreatePlanUseCaseTests.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Testing
import Foundation
@testable import LeanPaws

@MainActor
struct CreatePlanUseCaseTests {

    // Shared setup: a mock repository with one dog already saved
    let repository = MockDogProfileRepository()
    let max = Dog(name: "Max", breed: "Labrador", dateOfBirth: Date())

    init() throws {
        try repository.saveDog(max)
    }

    @Test("A plan with a goal below the starting weight is saved for the dog")
    func validPlanIsSaved() throws {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)

        let plan = try useCase.createPlan(
            forDogID: max.id,
            startWeightKg: 32,
            targetWeightKg: 28,
            dailyFoodAllowanceGrams: 320,
            dailyWalkTargetMinutes: 40
        )

        #expect(try repository.fetchPlan(forDogID: max.id) == plan)
    }

    @Test("A goal weight equal to the starting weight is rejected")
    func goalEqualToStartWeightIsRejected() {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)

        #expect(throws: CreatePlanError.targetNotBelowStartWeight) {
            try useCase.createPlan(
                forDogID: max.id,
                startWeightKg: 30,
                targetWeightKg: 30,
                dailyFoodAllowanceGrams: 320,
                dailyWalkTargetMinutes: 40
            )
        }
    }
    
    @Test("A daily food allowance of 0 grams is rejected")
    func zeroFoodAllowanceIsRejected() {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)

        #expect(throws: CreatePlanError.invalidFoodAllowance) {
            try useCase.createPlan(
                forDogID: max.id,
                startWeightKg: 32,
                targetWeightKg: 28,
                dailyFoodAllowanceGrams: 0,
                dailyWalkTargetMinutes: 40
            )
        }
    }

    @Test("A daily walking goal of 0 minutes is rejected")
    func zeroWalkTargetIsRejected() {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)
        
        #expect(throws: CreatePlanError.invalidWalkTarget){
            try useCase.createPlan(
                forDogID: max.id,
                startWeightKg: 32,
                targetWeightKg: 28,
                dailyFoodAllowanceGrams: 320,
                dailyWalkTargetMinutes: 0
            )
        }
    }

    @Test("A plan for a dog that hasn't been added is rejected")
    func planForUnknownDogIsRejected() {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)
        
        #expect(throws: CreatePlanError.dogNotFound) {
            try useCase.createPlan(
                forDogID: UUID(),
                startWeightKg: 32,
                targetWeightKg: 28,
                dailyFoodAllowanceGrams: 320,
                dailyWalkTargetMinutes: 40
            )
        }
    }

    @Test("The smallest valid allowance and walking goal are accepted")
    func smallestValidTargetsAreAccepted() throws {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)

        let plan = try useCase.createPlan(
            forDogID: max.id,
            startWeightKg: 32,
            targetWeightKg: 28,
            dailyFoodAllowanceGrams: 1,
            dailyWalkTargetMinutes: 1
        )

        #expect(try repository.fetchPlan(forDogID: max.id) == plan)
    }

    @Test("A rejected plan is not saved for the dog")
    func rejectedPlanIsNotSaved() throws {
        let useCase = CreatePlanUseCase(dogProfileRepository: repository)

        _ = try? useCase.createPlan(
            forDogID: max.id,
            startWeightKg: 30,
            targetWeightKg: 35,   // goal above start weight — invalid
            dailyFoodAllowanceGrams: 320,
            dailyWalkTargetMinutes: 40
        )

        #expect(try repository.fetchPlan(forDogID: max.id) == nil)
    }
}

