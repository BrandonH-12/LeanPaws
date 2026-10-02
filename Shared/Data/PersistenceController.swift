//
//  PersistenceController.swift
//  LeanPaws
//
//  Created by Brandon Hua on 2/10/2026.
//
import CoreData

/// Opens the LeanPaws database in the App Group container,
/// so the app, widget and notification all share the same data
final class PersistenceController {
    static let appGroupID = "group.com.brandon.leanpaws"   // your App Group identifier
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // inMemory: true gives a throwaway database, handy for SwiftUI previews
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LeanPaws")   // must match the model file name

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let sharedFolder = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        ) {
            // Put the database file inside the shared App Group folder
            let storeURL = sharedFolder.appendingPathComponent("LeanPaws.sqlite")
            container.persistentStoreDescriptions.first?.url = storeURL
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Couldn't open the LeanPaws database: \(error)")
            }
        }

        // Pick up changes saved elsewhere, and let the newest save win on conflicts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
