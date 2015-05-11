//
//  MenuBarController.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Cocoa

class MenuBarController: NSMenu {

	let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

	var isConnectionSelected = false

	var stopMenuItems = [NSMenuItem]()

	// FIXME: MenuBarController has to subscribe to kUpdatedNumRowsToShowNotification to update this property; use updateNumRowsToShowValue for the Selector
	// Also check if it might be better to send the value as the notification object instead of telling this when to load from NSUserDefaults
	var numRowsToShow = 5

	// MARK: -

	func updateMenu() {

	}

	func updateNumRowsToShowValue() {
		numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey(kNumRowsToShowKey)
	}

	// MARK: - Selections

	func selectConnection(sender: ConnectionMenuItem) {

	}

	func selectStop(sender: NSMenuItem) {
		ConnectionManager.shared().selectedStop = sender.title
		for stop in stopMenuItems {
			stop.state = NSOffState
		}
		sender.state = NSOnState

		isConnectionSelected = false
		ConnectionManager.shared().nuke()
		update()
	}

	// MARK: - IBActions

	@IBAction func clearNotificationButtonPressed(sender: NSMenuItem) {
		NotificationController.shared().removeScheduledNotification()
		ConnectionManager.shared().deselectAll()
		isConnectionSelected = false
		update()
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {
		appDelegate.settingsWindowController.display()
		NSApp.activateIgnoringOtherApps(true)
	}

	@IBAction func aboutButtonPressed(sender: NSMenuItem) {
		appDelegate.aboutWindowController.display()
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}
