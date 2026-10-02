//
//  CoreDataDogProfileRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import CoreData

/// Problems that can only happen at the database level
enum CoreDataRepositoryError: Error {
    case dogRecordMissing
}

/// Saves and reads dogs and their vet plans using Core Data in the shared App Group store
final class CoreDataDogProfileRepository: DogProfileRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // MARK: - Dogs

    func saveDog(_ dog: Dog) throws {
        // Update the existing record if this dog is already saved, otherwise create one
        let record = try fetchDogRecord(withID: dog.id) ?? DogEntity(context: context)
        record.id = dog.id
        record.name = dog.name
        record.breed = dog.breed
        record.dateOfBirth = dog.dateOfBirth
        try context.save()
    }

    func fetchDog(withID dogID: UUID) throws -> Dog? {
        try fetchDogRecord(withID: dogID)?.toDog()
    }

    func fetchAllDogs() throws -> [Dog] {
        let request = DogEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(request).compactMap { $0.toDog() }   // convert each record to a Dog
    }

    // MARK: - Plans

    func savePlan(_ plan: WeightPlan) throws {
        guard let dogRecord = try fetchDogRecord(withID: plan.dogID) else {
            throw CoreDataRepositoryError.dogRecordMissing
        }
        // One plan per dog: reuse the dog's existing plan record if there is one
        let record = dogRecord.plan ?? WeightPlanEntity(context: context)
        record.id = plan.id
        record.startWeightKg = plan.startWeightKg
        record.targetWeightKg = plan.targetWeightKg
        record.dailyFoodAllowanceGrams = Int32(plan.dailyFoodAllowanceGrams)
        record.dailyWalkTargetMinutes = Int32(plan.dailyWalkTargetMinutes)
        record.startDate = plan.startDate
        record.nextVetCheck = plan.nextVetCheck
        record.dog = dogRecord
        try context.save()
    }

    func fetchPlan(forDogID dogID: UUID) throws -> WeightPlan? {
        try fetchDogRecord(withID: dogID)?.plan?.toWeightPlan()
    }

    // MARK: - Helpers

    // Finds the stored record for one dog by its ID
    private func fetchDogRecord(withID dogID: UUID) throws -> DogEntity? {
        let request = DogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dogID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - Converting database records into domain models

extension DogEntity {
    func toDog() -> Dog? {
        guard let id, let name, let breed, let dateOfBirth else { return nil }
        return Dog(id: id, name: name, breed: breed, dateOfBirth: dateOfBirth)
    }
}

extension WeightPlanEntity {
    func toWeightPlan() -> WeightPlan? {
        guard let id, let dogID = dog?.id, let startDate else { return nil }
        return WeightPlan(
            id: id,
            dogID: dogID,
            startWeightKg: startWeightKg,
            targetWeightKg: targetWeightKg,
            dailyFoodAllowanceGrams: Int(dailyFoodAllowanceGrams),
            dailyWalkTargetMinutes: Int(dailyWalkTargetMinutes),
            startDate: startDate,
            nextVetCheck: nextVetCheck
        )
    }
}
