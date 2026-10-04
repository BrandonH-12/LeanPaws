//
//  PlanSetupView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI

/// The first screen after a vet visit: the owner enters their dog and the vet's targets
struct PlanSetupView: View {
    @State var viewModel: PlanSetupViewModel
    let onPlanSaved: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.needsDogDetails {
                    Section("Your dog") {
                        TextField("Name", text: $viewModel.dogName)
                        TextField("Breed", text: $viewModel.breed)
                        DatePicker("Date of birth", selection: $viewModel.dateOfBirth,
                                   in: ...Date(), displayedComponents: .date)
                    }
                }

                Section {
                    TextField("Current weight (kg)", text: $viewModel.startWeightText)
                        .keyboardType(.decimalPad)
                    TextField("Goal weight (kg)", text: $viewModel.targetWeightText)
                        .keyboardType(.decimalPad)
                    TextField("Daily food allowance (g), treats included", text: $viewModel.foodAllowanceText)
                        .keyboardType(.numberPad)
                    TextField("Daily walking goal (minutes)", text: $viewModel.walkTargetText)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Your vet's plan")
                } footer: {
                    Text("Copy these from what your vet recommended.")
                }

                Section("Next vet check") {
                    Toggle("Check-up booked", isOn: $viewModel.hasVetCheckBooked)
                    if viewModel.hasVetCheckBooked {
                        DatePicker("Date", selection: $viewModel.nextVetCheck,
                                   in: Date()..., displayedComponents: .date)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Save plan") {
                        if viewModel.savePlan() {
                            onPlanSaved()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Set up the vet's plan")
        }
    }
}

#Preview {
    PlanSetupView(
        viewModel: PlanSetupViewModel(existingDogID: nil, container: .preview()),
        onPlanSaved: {}
    )
}
