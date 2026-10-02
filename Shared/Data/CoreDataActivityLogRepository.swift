//
//  CoreDataActivityLogRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//

import CoreData

/// Saves and reads the food and walks an owner logs, using Core Data in the shared App Group store
final class CoreDataActivityLogRepository: ActivityLogRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // MARK: - Food

    func saveFoodEntry(_ foodEntry: FoodEntry) throws {
        guard let dogRecord = try fetchDogRecord(withID: foodEntry.dogID) else {
            throw CoreDataRepositoryError.dogRecordMissing
        }
        let record = FoodEntryEntity(context: context)
        record.id = foodEntry.id
        record.name = foodEntry.name
        record.foodType = foodEntry.type.rawValue   // store the enum as "regularMeal" or "treat"
        record.grams = Int32(foodEntry.grams)
        record.eatenAt = foodEntry.eatenAt
        record.dog = dogRecord
        try context.save()
    }

    func fetchFoodEntries(forDogID dogID: UUID, on day: Date) throws -> [FoodEntry] {
        let (startOfDay, startOfNextDay) = dayWindow(for: day)
        let request = FoodEntryEntity.fetchRequest()
        // The domain condition: this dog's food, eaten between midnight and the next midnight
        request.predicate = NSPredicate(
            format: "dog.id == %@ AND eatenAt >= %@ AND eatenAt < %@",
            dogID as CVarArg, startOfDay as NSDate, startOfNextDay as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "eatenAt", ascending: true)]
        return try context.fetch(request).compactMap { $0.toFoodEntry() }
    }

    // MARK: - Walks

    func saveWalkEntry(_ walkEntry: WalkEntry) throws {
        guard let dogRecord = try fetchDogRecord(withID: walkEntry.dogID) else {
            throw CoreDataRepositoryError.dogRecordMissing
        }
        let record = WalkEntryEntity(context: context)
        record.id = walkEntry.id
        record.walkedAt = walkEntry.walkedAt
        record.walkDurationMinutes = Int32(walkEntry.walkDurationMinutes)
        record.dog = dogRecord
        try context.save()
    }

    func fetchWalkEntries(forDogID dogID: UUID, on day: Date) throws -> [WalkEntry] {
        let (startOfDay, startOfNextDay) = dayWindow(for: day)
        let request = WalkEntryEntity.fetchRequest()
        // The domain condition: this dog's walks, taken between midnight and the next midnight
        request.predicate = NSPredicate(
            format: "dog.id == %@ AND walkedAt >= %@ AND walkedAt < %@",
            dogID as CVarArg, startOfDay as NSDate, startOfNextDay as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "walkedAt", ascending: true)]
        return try context.fetch(request).compactMap { $0.toWalkEntry() }
    }

    // MARK: - Helpers

    // Midnight at the start of the day, and midnight at the start of the next day
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

// MARK: - Converting database records into domain models

extension FoodEntryEntity {
    func toFoodEntry() -> FoodEntry? {
        guard let id, let dogID = dog?.id, let name, let eatenAt,
              let foodType, let type = FoodType(rawValue: foodType) else { return nil }
        return FoodEntry(id: id, dogID: dogID, name: name, type: type,
                         grams: Int(grams), eatenAt: eatenAt)
    }
}

extension WalkEntryEntity {
    func toWalkEntry() -> WalkEntry? {
        guard let id, let dogID = dog?.id, let walkedAt else { return nil }
        return WalkEntry(id: id, dogID: dogID, walkedAt: walkedAt,
                         walkDurationMinutes: Int(walkDurationMinutes))
    }
}
