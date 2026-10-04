//
//  WeightProgressView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI
import Charts

/// Shows the dog's weight trend toward the vet's goal and lets the owner record today's weight
struct WeightProgressView: View {
    @State var viewModel: WeightProgressViewModel

    var body: some View {
        Form {
            // Where the dog is now compared with the goal
            Section("Progress") {
                if let current = viewModel.currentWeightKg {
                    LabeledContent("Current weight", value: kilograms(current))
                }
                if let target = viewModel.targetWeightKg {
                    LabeledContent("Vet's goal", value: kilograms(target))
                }
                if let toGo = viewModel.kilogramsToGo {
                    LabeledContent("Still to lose", value: toGo == 0 ? "Goal reached" : kilograms(toGo))
                }
            }

            // The trend line the owner can show the vet
            Section("Weight over time") {
                if viewModel.weighIns.isEmpty {
                    Text("No weigh-ins yet. Weigh your dog about once a week to build a trend for your vet.")
                        .foregroundStyle(.secondary)
                } else {
                    Chart {
                        ForEach(viewModel.weighIns) { weighIn in
                            LineMark(x: .value("Date", weighIn.weighInDate),
                                     y: .value("Weight (kg)", weighIn.weightKg))
                            PointMark(x: .value("Date", weighIn.weighInDate),
                                      y: .value("Weight (kg)", weighIn.weightKg))
                        }
                        if let target = viewModel.targetWeightKg {
                            RuleMark(y: .value("Goal", target))
                                .foregroundStyle(.green)
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                                .annotation(position: .top, alignment: .leading) {
                                    Text("Goal \(kilograms(target))")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 200)
                }
            }

            // Recording today's weight
            Section("Record today's weight") {
                TextField("Weight (kg)", text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
                Button("Save weigh-in") {
                    viewModel.recordWeighIn()
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
                if let confirmationMessage = viewModel.confirmationMessage {
                    Text(confirmationMessage)
                        .foregroundStyle(.green)
                }
            }
        }
        .navigationTitle("Weight progress")
        .onAppear { viewModel.loadWeightHistory() }
    }

    // Shows a weight like "31.4 kg"
    private func kilograms(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) kg"
    }
}

#Preview {
    NavigationStack {
        WeightProgressView(viewModel: WeightProgressViewModel(dogID: UUID(), container: .preview()))
    }
}
