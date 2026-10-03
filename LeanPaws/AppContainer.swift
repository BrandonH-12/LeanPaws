//
//  AppContainer.swift
//  LeanPaws
//
//  Created by Brandon Hua on 3/10/2026.
//

import Foundation

/// Builds the app's repositories and use cases in one place and hands them to the screens
@MainActor
final class AppContainer {
    let dogProfileRepository: DogProfileRepository
    let activityLogRepository: ActivityLogRepository
    let weighInRepository: WeighInRepository

    init(dogProfileRepository: DogProfileRepository,
         activityLogRepository: ActivityLogRepository,
         weighInRepository: WeighInRepository) {
        self.dogProfileRepository = dogProfileRepository
        self.activityLogRepository = activityLogRepository
        self.weighInRepository = weighInRepository
    }

    /// The real app: Core Data in the shared App Group store
    static let live = AppContainer(
        dogProfileRepository: CoreDataDogProfileRepository(),
        activityLogRepository: CoreDataActivityLogRepository(),
        weighInRepository: CoreDataWeighInRepository()
    )

    /// SwiftUI previews: in-memory mocks, so nothing is saved
    static func preview() -> AppContainer {
        AppContainer(
            dogProfileRepository: MockDogProfileRepository(),
            activityLogRepository: MockActivityLogRepository(),
            weighInRepository: MockWeighInRepository()
        )
    }

    // MARK: - Use cases, built from whichever repositories this container holds

    var addDog: AddDogUseCase {
        AddDogUseCase(dogProfileRepository: dogProfileRepository)
    }
    var createPlan: CreatePlanUseCase {
        CreatePlanUseCase(dogProfileRepository: dogProfileRepository)
    }
    var logFood: LogFoodUseCase {
        LogFoodUseCase(dogProfileRepository: dogProfileRepository,
                       activityLogRepository: activityLogRepository)
    }
    var logWalk: LogWalkUseCase {
        LogWalkUseCase(dogProfileRepository: dogProfileRepository,
                       activityLogRepository: activityLogRepository)
    }
    var recordWeighIn: RecordWeighInUseCase {
        RecordWeighInUseCase(dogProfileRepository: dogProfileRepository,
                             weighInRepository: weighInRepository)
    }
    var checkDailyProgress: CheckDailyProgressUseCase {
        CheckDailyProgressUseCase(dogProfileRepository: dogProfileRepository,
                                  activityLogRepository: activityLogRepository)
    }
}
