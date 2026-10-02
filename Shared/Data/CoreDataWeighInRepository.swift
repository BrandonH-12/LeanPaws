//
//  CoreDataWeighInRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import CoreData

/// Saves and reads a dog's weigh-ins using Core Data in the shared App Group store
final class CoreDataWeighInRepository: WeighInRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func saveWeighIn(_ weighIn: WeighIn) throws {
        guard let dogRecord = try fetchDogRecord(withID: weighIn.dogID) else {
            throw CoreDataRepositoryError.dogRecordMissing
        }
        let record = WeighInEntity(context: context)
        record.id = weighIn.id
        record.weighInDate = weighIn.weighInDate
        record.weightKg = weighIn.weightKg
        record.dog = dogRecord
        try context.save()
    }

    // The dog's whole weight history, oldest first, for the progress chart
    func fetchAllWeighIns(forDogID dogID: UUID) throws -> [WeighIn] {
        let request = WeighInEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dog.id == %@", dogID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "weighInDate", ascending: true)]
        return try context.fetch(request).compactMap { $0.toWeighIn() }
    }

    // The dog's weigh-in on one day, if there is one (used for the one-per-day rule)
    func fetchWeighIn(forDogID dogID: UUID, on day: Date) throws -> WeighIn? {
        let (startOfDay, startOfNextDay) = dayWindow(for: day)
        let request = WeighInEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "dog.id == %@ AND weighInDate >= %@ AND weighInDate < %@",
            dogID as CVarArg, startOfDay as NSDate, startOfNextDay as NSDate
        )
        request.fetchLimit = 1
        return try context.fetch(request).first?.toWeighIn()
    }

    // MARK: - Helpers

    private func dayWindow(for day: Date) -> (Date, Date) {
        let startOfDay = Calendar.current.startOfDay(for: day)
        let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
            ?? startOfDay.addingTimeInterval(24 * 60 * 60)
        return (startOfDay, startOfNextDay)
    }

    private func fetchDogRecord(withID dogID: UUID) throws -> DogEntity? {
        let request = DogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dogID as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension WeighInEntity {
    func toWeighIn() -> WeighIn? {
        guard let id, let dogID = dog?.id, let weighInDate else { return nil }
        return WeighIn(id: id, dogID: dogID, weighInDate: weighInDate, weightKg: weightKg)
    }
}
