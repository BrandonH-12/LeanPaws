//
//  LogFoodView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI

/// Where the owner records a meal or treat their dog has eaten
struct LogFoodView: View {
    @State var viewModel: LogFoodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                Picker("Type", selection: $viewModel.foodType) {
                    ForEach(FoodType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                TextField("What was it? (e.g. dry kibble, dental chew)", text: $viewModel.foodName)
                TextField("Amount (g)", text: $viewModel.gramsText)
                    .keyboardType(.numberPad)
                DatePicker("Eaten at", selection: $viewModel.eatenAt, in: ...Date())
            } footer: {
                Text("Treats count toward the daily allowance too.")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Log food") {
                    if viewModel.logFood() {
                        dismiss()   // back to Today, which refreshes on appear
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Log food")
    }
}

#Preview {
    NavigationStack {
        LogFoodView(viewModel: LogFoodViewModel(dogID: UUID(), container: .preview()))
    }
}
