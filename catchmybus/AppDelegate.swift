//
//  AppDelegate.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 11/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

//  The term 'Bus' is used for both busses and trams in this app

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

	// Settings window
	@IBOutlet weak var settingsWindow: NSView!
	@IBOutlet weak var settingsView: NSWindow!	
	@IBOutlet weak var numRowsToShowLabel: NSTextField!
	@IBOutlet weak var numRowsToShowStepper: NSStepper!

	// NSMenu
	@IBOutlet weak var statusMenu: NSMenu!
	@IBOutlet weak var manualRefreshButtonLabel: NSMenuItem!
	@IBOutlet weak var stopLabelHelmholtz: NSMenuItem!
	@IBOutlet weak var stopLabelZelle: NSMenuItem!



	var stopLabels: [NSMenuItem] = []

	let cm = ConnectionManager()

	var numRowsToShow = 3	// how many rows are shown in the menu
	var numShownRows = 0	// tmp variable to store how many rows can be cleared on the next update

	var updateTime = 1		// how often in minutes the app calls update()

	var notificationTime = NSDate()
	var notificationBlockingstatusItem = false

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// initialize default NSUserDefaults
		var defaults: Dictionary<NSObject, AnyObject> = ["numRowsToShow" : 5, "stopDict" : cm.stopDict, "updateTime" : 1]
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)

		// load NSUserDefaults
		numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey("numRowsToShow")
		numRowsToShowLabel.integerValue = numRowsToShow
		numRowsToShowStepper.integerValue = numRowsToShow
		cm.stopDict = NSUserDefaults.standardUserDefaults().objectForKey("stopDict") as Dictionary
		updateTime = NSUserDefaults.standardUserDefaults().integerForKey("updateTime")

		// setup icons and NSMenuItems
		setupUI()

		// Update data and UI
		update()

		// initialize timer to automatically call update() how ever often updateTime states
		let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(updateTime * 60), target: self, selector: Selector("update"), userInfo: nil, repeats: true)

		// necessary for sending notifications when app is not active
		NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
	}

	func applicationWillTerminate(notification: NSNotification) {
		NSUserDefaults.standardUserDefaults().setInteger(numRowsToShow, forKey: "numRowsToShow")
		NSUserDefaults.standardUserDefaults().setObject(cm.stopDict, forKey: "stopDict")
		NSUserDefaults.standardUserDefaults().setInteger(updateTime, forKey: "updateTime")
	}

	// necessary for sending notifications when app is not active
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		return true
	}

	func setupUI() {
		let icon = NSImage(named: "statusIcon")
		icon?.setTemplate(true)

		// Initialize stopLabels array (this stuff has got to move away from here eventually...)
		// and definitely not be hardcoded like this
		stopLabels.append(stopLabelHelmholtz)
		stopLabels.append(stopLabelZelle)

		statusItem.image = icon
		statusItem.menu = statusMenu
	}

	func update() {
		// clear connection rows in menu
		for i in 0..<numShownRows {
			self.statusMenu.removeItemAtIndex(0)
		}

		// pull new data and update UI in callback
		numShownRows = 0
		cm.clear()
		cm.update({
			if self.notificationBlockingstatusItem {
				self.statusItem.title = "WFN" // Waiting for Notification
				self.statusItem.title = "WFN" // this has to wait for the new connection management
			} else {
				// update the statusMenu.title
				// done twice on purpose to clear the necessary space
				if let firstBusArrivalMinutes = self.cm.connections.first?.arrivalMinutes {
					self.statusItem.title = "\(self.cm.connections.first!.arrivalMinutes)"
					self.statusItem.title = "\(self.cm.connections.first!.arrivalMinutes)"
				}
			}

			// loop through connections to update NSMenuItems
			var i = 0
			for connection in self.cm.connections {
				if (i == self.numRowsToShow) {
					break
				}
				let connectionMenuItem = ConnectionMenuItem(connection: connection, title: connection.toString(), action: Selector("connectionSelected:"), keyEquivalent: "")
				if connection.selected {
					connectionMenuItem.state = NSOnState
				}
				self.statusMenu.insertItem(connectionMenuItem, atIndex: i)
				self.numShownRows++
				i++
			}
		})

		// show new busses in the menubar after a notified connection is through
		let currentTime = NSDate()
		if (currentTime.laterDate(notificationTime.dateByAddingTimeInterval(NSTimeInterval(15 * 60))) == currentTime) {
			notificationBlockingstatusItem = false
		}
	}

	// Settings window
	@IBAction func numRowsToShowStepperClicked(sender: NSStepper) {
		numRowsToShowLabel.integerValue = sender.integerValue
		numRowsToShow = sender.integerValue
	}



	// NSMenu
	@IBAction func refreshClicked(sender: NSMenuItem) {
		update()
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {
		settingsView.makeKeyAndOrderFront(sender)
		NSApp.activateIgnoringOtherApps(true)
	}
	
	@IBAction func selectStop(sender: NSMenuItem) {
		self.cm.selectedStop = sender.title
		for label in stopLabels {
			label.state = NSOffState
		}
		sender.state = NSOnState
		cm.nuke()
		update()
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}

	func connectionSelected(sender: ConnectionMenuItem) {
		NSLog("Set a notification for \(sender.connection.toString())")
		notificationTime = NSDate(timeInterval: NSTimeInterval(-15 * 60), sinceDate: sender.connection.arrivalDate)

		// TODO: Send a notification right now stating when the user will be notified

		// register notification to be sent at time of notification
		let notification = NSUserNotification()
		notification.title = "Catch your bus!"
		notification.informativeText = "Your bus is leaving soon."
		notification.deliveryDate = notificationTime
		NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)

		notificationBlockingstatusItem = true

		sender.connection.selected = true

		// update UI for the new statusitem.title
		update()
	}
}

