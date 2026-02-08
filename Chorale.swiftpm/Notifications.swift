//
//  File.swift
//  MoodScape
//
//  Created by Thuc Anh "Christina" Vu on 2/7/26.
//

import Foundation
import UserNotifications

enum Notifier {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
            DispatchQueue.main.async { completion(ok) }
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["moodscape.daily"])

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "MoodScape"
        content.body = "Quick check-in: how are you feeling right now?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "moodscape.daily", content: content, trigger: trigger)
        center.add(req)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["moodscape.daily"])
    }
}
