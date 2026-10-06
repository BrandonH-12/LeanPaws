//
//  CheckInNotifications.swift
//  LeanPaws
//
//  Created by Brandon Hua on 4/10/2026.
//

import Foundation
import UserNotifications

/// Sets up the evening check-in that shows the owner how their dog's day is going
enum CheckInNotifications {
    static let categoryID = "DAILY_CHECK_IN"            // the notification extension listens for this
    static let logWalkActionID = "LOG_WALK"
    private static let dailyCheckInID = "daily-check-in"

    /// Tells iOS about the check-in's "Log a walk" action, where the owner types the minutes walked
    static func registerCategory() {
        let logWalk = UNTextInputNotificationAction(identifier: logWalkActionID,
                                            title: "Log a walk",
                                            options: [],
                                            textInputButtonTitle: "Log",
                                            textInputPlaceholder: "Minutes walked, e.g. 25")
        let checkIn = UNNotificationCategory(identifier: categoryID,
                                             actions: [logWalk],
                                             intentIdentifiers: [],
                                             options: [])
        UNUserNotificationCenter.current().setNotificationCategories([checkIn])
    }

    /// Asks the owner for permission, then schedules the check-in for 7pm every day
    static func requestPermissionAndSchedule(dogName: String) async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

        var sevenPM = DateComponents()
        sevenPM.hour = 19
        let trigger = UNCalendarNotificationTrigger(dateMatching: sevenPM, repeats: true)
        let request = UNNotificationRequest(identifier: dailyCheckInID,
                                            content: checkInContent(dogName: dogName),
                                            trigger: trigger)
        try? await center.add(request)
    }

    #if DEBUG
    /// Sends a check-in 5 seconds from now, for testing without waiting until 7pm
    static func sendTestCheckIn(dogName: String) async {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: checkInContent(dogName: dogName),
                                            trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
    #endif

    private static func checkInContent(dogName: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "How's \(dogName)'s day going?"
        content.body = "Check today's food and walking against the vet's plan."
        content.categoryIdentifier = categoryID
        content.sound = .default
        return content
    }
}

