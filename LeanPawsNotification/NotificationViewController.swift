//
//  NotificationViewController.swift
//  LeanPawsNotification
//
//  Created by Brandon Hua on 1/10/2026.
//

import UIKit
import SwiftUI
import UserNotifications
import UserNotificationsUI
import WidgetKit

/// Shows today's progress inside the evening check-in and lets the owner log a walk by typing the minutes
class NotificationViewController: UIViewController, UNNotificationContentExtension {
    // Comes from the template's storyboard; kept (and hidden) so the storyboard still loads
    @IBOutlet var label: UILabel?

    private var hostingController: UIHostingController<CheckInProgressView>?
    private let dogProfiles = CoreDataDogProfileRepository()
    private let activityLog = CoreDataActivityLogRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        label?.isHidden = true
        showTodaysProgress(message: nil)
    }

    // Called when the owner opens the check-in
    func didReceive(_ notification: UNNotification) {
        showTodaysProgress(message: nil)
    }

    // Called when the owner types how long they walked and taps "Log"
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        guard response.actionIdentifier == CheckInNotifications.logWalkActionID,
              let typedResponse = response as? UNTextInputNotificationResponse else {
            completion(.dismissAndForwardAction)
            return
        }

        // The owner types the minutes, so check it's a whole number first
        let typedMinutes = typedResponse.userText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let minutes = Int(typedMinutes) else {
            showTodaysProgress(message: "Enter the walk length in minutes as a whole number, for example 25.")
            completion(.doNotDismiss)
            return
        }

        do {
            guard let dog = try dogProfiles.fetchAllDogs().first else {
                completion(.dismiss)
                return
            }
            // Same use case and rules as the Log walk screen (plan exists, at least 1 minute, not in the future)
            _ = try LogWalkUseCase(dogProfileRepository: dogProfiles, activityLogRepository: activityLog)
                .logWalk(forDogID: dog.id, durationMinutes: minutes)
            WidgetCenter.shared.reloadAllTimelines()
            showTodaysProgress(message: "\(minutes)-minute walk logged.")
        } catch {
            showTodaysProgress(message: error.ownerFacingMessage)
        }

        // Keep the notification open so the owner sees the updated progress
        completion(.doNotDismiss)
    }

    // Loads today's progress with the same use case as the app and widget, then shows it
    private func showTodaysProgress(message: String?) {
        var progress: DailyProgress?
        if let dog = try? dogProfiles.fetchAllDogs().first {
            progress = try? CheckDailyProgressUseCase(dogProfileRepository: dogProfiles,
                                                      activityLogRepository: activityLog)
                .checkProgress(forDogID: dog.id)
        }
        let checkInView = CheckInProgressView(progress: progress, message: message)

        if let hostingController {
            hostingController.rootView = checkInView
        } else {
            embed(checkInView)
        }
    }

    // Places the SwiftUI view inside this UIKit screen
    private func embed(_ checkInView: CheckInProgressView) {
        let host = UIHostingController(rootView: checkInView)
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host
        preferredContentSize = CGSize(width: view.bounds.width, height: 200)
    }
}
