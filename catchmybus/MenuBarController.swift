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

	var numRowsToShow = 5

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		// TODO: Check if it might be better to send the value as the notification object instead of telling this when to load from NSUserDefaults
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNumRowsToShowValue", name: kUpdatedNumRowsToShowNotification, object: nil)
	}

	// MARK: -

	func updateMenu() {

	}

	func updateNumRowsToShowValue() {
		numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey(kNumRowsToShowKey)
		// TODO: Probably reload the menu here to display the changed value?
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
