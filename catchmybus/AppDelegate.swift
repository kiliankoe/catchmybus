//
//  AppDelegate.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 11/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

//  The term 'Bus' is used for both busses and trams in this app

import Cocoa
import Fabric
import Crashlytics
import SwiftyTimer

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

	// TODO: Remove these references, the windows probably shouldn't be held in memory all the time the app is running
	let settingsWindowController = SettingsWindowController()
	let aboutWindowController = AboutWindowController()

	let menuController = MenuController()
	let connectionManager = ConnectionManager()

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		Fabric.with([Crashlytics()])

		// initialize default NSUserDefaults
		let defaultStopDict = ["Helmholtzstraße": 1, "Zellescher Weg": 5, "Heinrich-Zille-Straße": 8, "Technische Universität": 1]
		let defaultNotificationDict = ["Helmholtzstraße": 5, "Zellescher Weg": 15, "Heinrich-Zille-Straße": 15, "Technische Universität": 3]
		let defaults: [String: AnyObject] = [kNumRowsToShowKey : 5, kStopDictKey : defaultStopDict, kNotificationDictKey: defaultNotificationDict, kSelectedStopKey: "Helmholtzstraße"]
		NSUserDefaults.standardUserDefaults().registerDefaults(defaults)

		// setup statusItem
		let icon = NSImage(named: "statusIcon")
		icon?.template = true
		statusItem.image = icon
		statusItem.menu = MenuController()

		// Update data and UI
		update()

		// initialize timer to automatically call update() every 60 seconds
		NSTimer.every(60.seconds, update)

		// necessary for sending notifications when app is not active
		NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
	}

	// necessary for sending notifications when app is not active
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		return true
	}

	func update() {
		// Update menu by kicking all connections that are no longer relevant
		menuController.updateMenu()

		// pull new data from API

		// update UI
			// check to see if the statusicon should be set to a custom connection if one is selected
			// create new connectionmenuitems for all connections and add these to the menu
			// if a notified connection has passed, set the firstmost connection to the statusitem


	}
}
