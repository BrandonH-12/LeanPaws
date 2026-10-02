//
//  WeighInRepository.swift
//  LeanPaws
//
//  Created by Brandon Hua on 1/10/2026.
//

import Foundation
/// Records a dog's weigh-ins and reads them back for the progress chart and daily check
protocol WeighInRepository {
    func saveWeighIn(_ weighIn: WeighIn) throws
    func fetchAllWeighIns(forDogID dogID: UUID) throws -> [WeighIn]
    func fetchWeighIn(forDogID dogID: UUID, on day: Date) throws -> WeighIn?
}
