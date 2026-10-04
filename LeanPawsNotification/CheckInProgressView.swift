//
//  CheckInProgressView.swift
//  LeanPawsNotification
//
//  Created by Brandon Hua on 4/10/2026.
//

import Foundation
import SwiftUI

/// The custom check-in view: how the dog is tracking today, shown inside the notification
struct CheckInProgressView: View {
    let progress: DailyProgress?
    let message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let progress {
                Text("\(progress.dogName)'s day so far")
                    .font(.headline)

                Label(progress.isOverFoodAllowance
                      ? "Over today's food allowance"
                      : "\(progress.foodRemainingGrams) g of food left, treats included",
                      systemImage: "fork.knife")
                    .foregroundStyle(progress.isOverFoodAllowance ? .orange : .primary)
                ProgressView(value: Double(min(progress.foodEatenGrams, progress.foodAllowanceGrams)),
                             total: Double(progress.foodAllowanceGrams))

                Label(progress.hasMetWalkTarget
                      ? "Walking goal met"
                      : "\(progress.walkTargetMinutes - progress.walkedMinutes) min of walking to go",
                      systemImage: "figure.walk")
                ProgressView(value: Double(min(progress.walkedMinutes, progress.walkTargetMinutes)),
                             total: Double(progress.walkTargetMinutes))
            } else {
                Text("Open LeanPaws to add your vet's plan.")
            }

            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
