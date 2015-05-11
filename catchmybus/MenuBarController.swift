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
	let notification = NSUserNotification()

	var isConnectionSelected = false

	var stopMenuItems = [NSMenuItem]()

	// MARK: -

	func updateMenu() {

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
		NSUserNotificationCenter.defaultUserNotificationCenter().removeScheduledNotification(notification)
		ConnectionManager.shared().deselectAll()
		isConnectionSelected = false
		update()
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {
		appDelegate.settingsWindow.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
	}

	@IBAction func aboutButtonPressed(sender: NSMenuItem) {
		appDelegate.aboutWindowController.display()
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}
