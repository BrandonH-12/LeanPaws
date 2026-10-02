//
//  MockWeighInRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation

///An in-memory stand-in for the real database's weigh-in history, used by tests and previews
class MockWeighInRepository: WeighInRepository {
    
    var savedWeighIns: [WeighIn] = []
    
    func saveWeighIn(_ weighIn: WeighIn) throws {
        savedWeighIns.append(weighIn)
    }
    
    func fetchAllWeighIns(forDogID dogID: UUID) throws -> [WeighIn] {
        savedWeighIns.filter { $0.dogID == dogID }
    }
    
    func fetchWeighIn(forDogID dogID: UUID, on day: Date) throws -> WeighIn? {
        savedWeighIns.first(where: { $0.dogID == dogID && Calendar.current.isDate($0.weighInDate, inSameDayAs: day) })
    }
}
