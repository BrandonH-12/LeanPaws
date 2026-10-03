//
//  LeanPawsApp.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import SwiftUI

@main
struct LeanPawsApp: App {
    init() {
        #if DEBUG
        DebugSampleData.addIfEmpty()
        #endif
    }
    var body: some Scene {
        WindowGroup {
            RootView(container: .live)
        }
    }
}
