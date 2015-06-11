//
//  MenuBarController.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Cocoa
import Sparkle

class MenuController: NSMenu {

	let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

	var isConnectionSelected = false

	var stopMenuItems = [NSMenuItem]()

	var numRowsToShow = 5

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		fatalError("Initialized NSMenu through init(coder:). Wat?")
	}

	init() {
		// FIXME: Why is this not throwing errors with init(title:), but init() is not ok?
		super.init(title: "")

		setupMainMenuItems()

		// TODO: Check if it might be better to send the value as the notification object instead of telling this when to load from NSUserDefaults
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNumRowsToShowValue", name: kUpdatedNumRowsToShowNotification, object: nil)
	}

	/**
	Sets up the main NSMenuItems for the menu, so it'll look like this:
	
	[Connections will be listed here]
	-----
	[Stops will be listed here]
	-----
	Settings...
	Check for updates...
	About...
	Quit

	*/
	private func setupMainMenuItems() {
		// Connections will be listed here
		self.addItem(NSMenuItem.separatorItem())
		// Stops will be listed here
		self.addItem(NSMenuItem.separatorItem())
		self.addItem(ClosureMenuItem(title: "Settings...", keyEquivalent: ",", action: { () -> () in
			self.appDelegate.settingsWindowController.display()
		}))
		self.addItem(ClosureMenuItem(title: "Check for updates...", keyEquivalent: "", action: { () -> () in
			let updater = SUUpdater(forBundle: NSBundle.mainBundle())
			updater.checkForUpdates(updater)
		}))
		self.addItem(ClosureMenuItem(title: "About...", keyEquivalent: "", action: { () -> () in
			self.appDelegate.aboutWindowController.display()
		}))
		self.addItem(NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "q"))
	}

	/**
	Sets up the NSMenuItems for all saved stops
	*/
	private func setupStopMenuItems() {
		for stop in ConnectionManager.shared().stopDict {
			let stopMenuItem = NSMenuItem(title: stop.0, action: "selectStop:", keyEquivalent: "")
			stopMenuItems.append(stopMenuItem)
			self.insertItem(stopMenuItem, atIndex: 1)
			if (stop.0 == ConnectionManager.shared().selectedStop) {
				stopMenuItem.state = NSOnState
			}
		}
	}

	// MARK: -

	func updateMenu() {
		// TODO: Remove all rows that are now outdated and add in correct number of new ones
	}

	func updateNumRowsToShowValue() {
		numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey(kNumRowsToShowKey)
		// TODO: Probably reload the menu here to display the changed value?
	}

	// MARK: - Selections

	func selectConnection(sender: ConnectionMenuItem) {
		// clear a possible previous notification
		// show a notification about the upcoming notification
		// schedule notification for time when bus comes - 15 minutes
		// set statusitem for the selected connection
	}

	func selectStop(sender: NSMenuItem) {
		ConnectionManager.shared().selectedStop = sender.title
		for stop in stopMenuItems {
			stop.state = NSOffState
		}
		sender.state = NSOnState

		isConnectionSelected = false

		ConnectionManager.shared().nuke()
		ConnectionManager.shared().saveDefaults()
		
		update()
	}

	// MARK: - Actions

	// TODO: Remove me in favor of removing the notification by clicking on the selected connection again
	func clearNotificationButtonPressed(sender: NSMenuItem) {
		NotificationController.shared().removeScheduledNotification()
		ConnectionManager.shared().deselectAll()
		isConnectionSelected = false
		update()
	}
}
