//
//  OwnerErrorMessage.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation

extension Error {
    /// What went wrong and what to do next, in the owner's words
    var ownerFacingMessage: String {
        let localized = self as? LocalizedError
        let problem = localized?.errorDescription ?? "Something went wrong."
        let nextStep = localized?.recoverySuggestion ?? "Please try again."
        return "\(problem) \(nextStep)"
    }
}
