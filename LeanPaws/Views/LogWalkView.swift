//
//  LogWalkView.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import SwiftUI

/// Where the owner records a walk they took their dog on
struct LogWalkView: View {
    @State var viewModel: LogWalkViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("How long? (minutes)", text: $viewModel.minutesText)
                    .keyboardType(.numberPad)
                DatePicker("Walked at", selection: $viewModel.walkedAt, in: ...Date())
            } footer: {
                Text("Every walk counts toward today's walking goal.")
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Log walk") {
                    if viewModel.logWalk() {
                        dismiss()   // back to Today, which refreshes on appear
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Log a walk")
    }
}

#Preview {
    NavigationStack {
        LogWalkView(viewModel: LogWalkViewModel(dogID: UUID(), container: .preview()))
    }
}
