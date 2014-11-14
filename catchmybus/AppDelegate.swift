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

	@IBOutlet weak var statusMenu: NSMenu!
	@IBOutlet weak var settingsWindow: NSView!
	@IBOutlet weak var manualRefreshButtonLabel: NSMenuItem!

	@IBOutlet weak var stopLabelHelmholtz: NSMenuItem!
	@IBOutlet weak var stopLabelZelle: NSMenuItem!

	var stopLabels: [NSMenuItem] = []

	let cm = ConnectionManager()

	var numRowsToShow = 3
	var numShownRows = 0

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let icon = NSImage(named: "statusIcon")
		icon?.setTemplate(true)

		// Initialize stopLabels array (this stuff has got to move away from here eventually...)
		// and definitely not be hardcoded like this
		stopLabels.append(stopLabelHelmholtz)
		stopLabels.append(stopLabelZelle)

		statusItem.image = icon
		statusItem.menu = statusMenu

		update()

		// initialize default NSUserDefaults
		var defaults: Dictionary<NSObject, AnyObject> = ["numRowsToShow": 5]
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)

		// load NSUserDefaults
		numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey("numRowsToShow")

		// initialize timer to automatically call update() every minute
		var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
	}

	func applicationWillTerminate(notification: NSNotification) {
		NSUserDefaults.standardUserDefaults().setObject(numRowsToShow, forKey: "numRowsToShow")
	}

	func update() {
		NSLog("UPDATING")

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
				self.statusMenu.insertItemWithTitle(connection.toString(), action: nil, keyEquivalent: "", atIndex: i)
				self.numShownRows++
				i++
			}
			NSLog("UPDATE FINISHED")
		})
	}

	@IBAction func refreshClicked(sender: NSMenuItem) {
		update()
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {

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
}

