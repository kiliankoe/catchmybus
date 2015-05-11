//
//  NotificationController.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

private let _NotificationControllerSharedInstance = NotificationController()

class NotificationController {

	// NotificationController is a singleton, accessible via NotificationController.shared()
	static func shared() -> NotificationController {
		return _NotificationControllerSharedInstance
	}

	// MARK: -

	var notification: NSUserNotification
	var notificationTime: NSDate
	var shouldDisplayNotifications: Bool

	// MARK: -

	init () {
		notification = NSUserNotification()
		notificationTime = NSDate()

		shouldDisplayNotifications = NSUserDefaults.standardUserDefaults().boolForKey(kShouldDisplayNotifications)

		// TODO: Check if it might be better to send the bool state as the notification object instead of using it as a note to load from NSUserDefaults
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateShouldDisplayNotification", name: kUpdatedShouldDisplayUserNotificationNotification, object: nil)
	}

	private func updateShouldDisplayNotification() {
		shouldDisplayNotifications = NSUserDefaults.standardUserDefaults().boolForKey(kShouldDisplayNotifications)
	}

	// MARK: - Handle user notifications

	internal func scheduleNotification(notificationDate: NSDate) {
		// TODO: Adjust notification date
		if shouldDisplayNotifications {
			NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
		}
	}

	internal func removeScheduledNotification() {
		NSUserNotificationCenter.defaultUserNotificationCenter().removeScheduledNotification(notification)
	}

}
