//
//  TodayView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI

/// The owner's daily dashboard: food and walking progress against the vet's plan
struct TodayView: View {
    @State var viewModel: TodayViewModel

    var body: some View {
        NavigationStack {
            List {
                if let progress = viewModel.progress {
                    // Food
                    Section("Food today") {
                        Text("\(progress.foodEatenGrams) of \(progress.foodAllowanceGrams) g eaten")
                            .font(.headline)
                        ProgressView(value: Double(min(progress.foodEatenGrams, progress.foodAllowanceGrams)),
                                     total: Double(progress.foodAllowanceGrams))
                            .tint(progress.isOverFoodAllowance ? .orange : .green)
                        if progress.isOverFoodAllowance {
                            Label("Over today's allowance. Skip extra treats for the rest of the day.",
                                  systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        } else if progress.foodEatenGrams == 0 {
                            Text("No meals logged yet today.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(progress.foodRemainingGrams) g left, treats included.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Walks
                    Section("Walking today") {
                        Text("\(progress.walkedMinutes) of \(progress.walkTargetMinutes) min walked")
                            .font(.headline)
                        ProgressView(value: Double(min(progress.walkedMinutes, progress.walkTargetMinutes)),
                                     total: Double(progress.walkTargetMinutes))
                            .tint(.blue)
                        if progress.hasMetWalkTarget {
                            Label("Walking goal met today.", systemImage: "checkmark.circle")
                                .foregroundStyle(.green)
                        } else if progress.walkedMinutes == 0 {
                            Text("No walks logged yet today.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(progress.walkTargetMinutes - progress.walkedMinutes) min to go.")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                // The owner's next actions
                Section {
                    NavigationLink("Log food") { LogFoodView(viewModel: LogFoodViewModel(dogID: viewModel.dogID, container: viewModel.container)) }
                    NavigationLink("Log a walk") { LogWalkView(viewModel: LogWalkViewModel(dogID: viewModel.dogID, container: viewModel.container)) }
                    NavigationLink("Weight progress") { WeightProgressView(viewModel: WeightProgressViewModel(dogID: viewModel.dogID, container: viewModel.container)) }
                }
                #if DEBUG
                Section("Try the evening check-in"){
                    Button("Send a test check-in notification in 5 seconds") {
                        Task{ await CheckInNotifications.sendTestCheckIn(dogName: viewModel.progress?.dogName ?? "your dog")}
                    }
                }
                #endif
            }
            .navigationTitle(viewModel.progress.map { "\($0.dogName)'s day" } ?? "Today")
            .onAppear { viewModel.loadTodaysProgress() }   // also refreshes after coming back from logging
            .task { await viewModel.setUpEveningCheckIn() }
        }
    }
}
