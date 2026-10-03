//
//  LeanPawsWidget.swift
//  LeanPawsWidget
//
//  Created by Brandon Hua on 1/10/2026.
//

import WidgetKit
import SwiftUI

/// One snapshot of the dog's day for the widget to show
struct DailyProgressEntry: TimelineEntry {
    let date: Date
    let progress: DailyProgress?   // nil when there's no dog or plan yet
}

/// Reads today's progress from the shared database using the same use case as the app
struct DailyProgressProvider: TimelineProvider {

    // Shown while the widget is loading or in the widget gallery
    func placeholder(in context: Context) -> DailyProgressEntry {
        DailyProgressEntry(date: Date(), progress: DailyProgress(
            dogName: "Max", foodEatenGrams: 170, foodAllowanceGrams: 320,
            walkedMinutes: 25, walkTargetMinutes: 40))
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyProgressEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : loadTodaysEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyProgressEntry>) -> Void) {
        // Refresh just after midnight so each new day starts from zero;
        // the app also reloads the widget whenever the owner logs something
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let justAfterMidnight = Calendar.current.date(byAdding: .minute, value: 24 * 60 + 1, to: startOfToday)
            ?? Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [loadTodaysEntry()], policy: .after(justAfterMidnight)))
    }

    private func loadTodaysEntry() -> DailyProgressEntry {
        let dogProfiles = CoreDataDogProfileRepository()
        let checkDailyProgress = CheckDailyProgressUseCase(
            dogProfileRepository: dogProfiles,
            activityLogRepository: CoreDataActivityLogRepository())

        guard let dog = try? dogProfiles.fetchAllDogs().first,
              let progress = try? checkDailyProgress.checkProgress(forDogID: dog.id) else {
            return DailyProgressEntry(date: Date(), progress: nil)
        }
        return DailyProgressEntry(date: Date(), progress: progress)
    }
}

/// What the owner sees on the Home Screen or Lock Screen
struct LeanPawsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DailyProgressEntry

    var body: some View {
        if let progress = entry.progress {
            switch family {
            case .accessoryRectangular:
                lockScreenView(progress)
            default:
                homeScreenView(progress)
            }
        } else {
            // Empty state, in the owner's words
            Text("Open LeanPaws to add your vet's plan")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }

    // Small Home Screen widget: food and walking progress at a glance
    private func homeScreenView(_ progress: DailyProgress) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(progress.dogName)'s day")
                .font(.headline)

            Label("\(progress.foodEatenGrams) / \(progress.foodAllowanceGrams) g", systemImage: "fork.knife")
                .font(.caption)
                .foregroundStyle(progress.isOverFoodAllowance ? .orange : .primary)
            ProgressView(value: Double(min(progress.foodEatenGrams, progress.foodAllowanceGrams)),
                         total: Double(progress.foodAllowanceGrams))

            Label("\(progress.walkedMinutes) / \(progress.walkTargetMinutes) min", systemImage: "figure.walk")
                .font(.caption)
            ProgressView(value: Double(min(progress.walkedMinutes, progress.walkTargetMinutes)),
                         total: Double(progress.walkTargetMinutes))
        }
    }

    // Lock Screen widget: what's left today, readable without unlocking
    private func lockScreenView(_ progress: DailyProgress) -> some View {
        VStack(alignment: .leading) {
            Text(progress.dogName).font(.headline)
            Text(progress.isOverFoodAllowance
                 ? "Over food allowance"
                 : "\(progress.foodRemainingGrams) g food left")
            Text("\(progress.walkedMinutes) of \(progress.walkTargetMinutes) min walked")
        }
        .font(.caption)
    }
}

struct LeanPawsWidget: Widget {
    let kind = "LeanPawsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyProgressProvider()) { entry in
            LeanPawsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Plan")
        .description("See how your dog is tracking against the vet's food and walking targets.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])   // the spec's two families
    }
}
