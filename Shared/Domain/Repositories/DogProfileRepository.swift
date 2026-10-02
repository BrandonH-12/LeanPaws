//
//  DogProfileRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation
/// Reads and saves a dog's profile and the vet's weight plan for that dog

protocol DogProfileRepository {
    func saveDog(_ dog:Dog) throws
    func fetchDog(withID dogID: UUID) throws -> Dog?
    
    func savePlan(_ plan: WeightPlan) throws
    func fetchPlan(forDogID dogID: UUID) throws -> WeightPlan?
    
    func fetchAllDogs() throws -> [Dog]
    
}
