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
class AppDelegate: NSObject, NSApplicationDelegate {

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

	var notificationSet = false
	var notificationTime = NSDate()

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

		// check the notification every 15 seconds
		let notificationTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("updateNotification"), userInfo: nil, repeats: true)
	}

	func applicationWillTerminate(notification: NSNotification) {
		NSUserDefaults.standardUserDefaults().setInteger(numRowsToShow, forKey: "numRowsToShow")
		NSUserDefaults.standardUserDefaults().setObject(cm.stopDict, forKey: "stopDict")
		NSUserDefaults.standardUserDefaults().setInteger(updateTime, forKey: "updateTime")
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

	func updateNotification() {
		if notificationSet {
			let currentDate = NSDate()
//			NSLog("Notification is set, and current date: \(currentDate.description)")
//			NSLog("Date of notification:                  \(notificationTime.description)")
			if (currentDate.laterDate(notificationTime) == currentDate) {
				NSLog("This is a notification, at least for now.")
				notificationSet = false
			}
		}
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
			// update the statusMenu.title
			// done twice on purpose to clear the necessary space
			self.statusItem.title = "\(self.cm.connections.first!.arrivalMinutes)"
			self.statusItem.title = "\(self.cm.connections.first!.arrivalMinutes)"

			// loop through connections to update NSMenuItems
			var i = 0
			for connection in self.cm.connections {
				if (i == self.numRowsToShow) {
					break
				}
				let connectionMenuItem = ConnectionMenuItem(connection: connection, title: connection.toString(), action: Selector("connectionSelected:"), keyEquivalent: "")
				self.statusMenu.insertItem(connectionMenuItem, atIndex: i)
				self.numShownRows++
				i++
			}
		})
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
		update()
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}

	func connectionSelected(sender: ConnectionMenuItem) {
		NSLog("Set a notification for \(sender.connection.toString())")
		notificationTime = NSDate(timeInterval: NSTimeInterval(-15 * 60), sinceDate: sender.connection.arrivalTime)
		notificationSet = true
		// this is temporary for now, ConnectionManager will have to able to track
		// connections for this to be a viable option
		sender.state = NSOnState
	}
}

