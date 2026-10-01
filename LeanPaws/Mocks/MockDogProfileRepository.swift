//
//  MockDogProfileRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation
/// An in-memory stand-in for the real database, used by tests and previews.
class MockDogProfileRepository: DogProfileRepository {
    
    var savedDogs: [Dog] = []
    var savedPlans: [WeightPlan] = []
    
    func saveDog(_ dog: Dog) throws {
        savedDogs.removeAll(where: { $0.id == dog.id })
        savedDogs.append(dog)
    }
    
    func fetchDog(withID dogID: UUID) throws -> Dog? {
        savedDogs.first(where: { $0.id == dogID })
    }
    
    func fetchAllDogs() throws -> [Dog] {
        savedDogs
    }
    
    func savePlan(_ plan: WeightPlan) throws {
        savedPlans.removeAll(where: { $0.dogID == plan.dogID })
        savedPlans.append(plan)
    }
    
    func fetchPlan(forDogID dogID: UUID) throws -> WeightPlan? {
        savedPlans.first(where: { $0.dogID == dogID })
    }
    
}
