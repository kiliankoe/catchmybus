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

	@IBOutlet weak var firstBusLabel: NSMenuItem!
	@IBOutlet weak var stopLabel: NSMenuItem!

	var selectedStop = "Helmholtzstrasse"

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let icon = NSImage(named: "statusIcon")
		icon?.setTemplate(true)

		statusItem.image = icon
		statusItem.menu = statusMenu

		// fake a refresh when starting
		refreshClicked(stopLabel)

		var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: true)
	}

	func updateUI() {
		// let's fake this for now
		refreshClicked(stopLabel)
	}

	@IBAction func refreshClicked(sender: NSMenuItem) {
		println("Manual refresh button clicked")
		let requestURL = "http://simpledvb.herokuapp.com/api/monitor/\(selectedStop)"
		Alamofire.request(.GET, requestURL)
			.responseJSON { (_, _, JSON, _) in
				let resultsArray : [Dictionary<String, AnyObject>] = JSON as [Dictionary]
				let firstResult = resultsArray[0] //FIXME: This sometimes throws an array out of bounds errors, why?
				if (resultsArray.count > 0) {

					// set the next bus' arrivaltime in the statusbar title
					if let firstBusMinutes : NSNumber = firstResult["arrivaltime"] as? NSNumber {
						if let firstBusDirection : String = firstResult["direction"] as? String {
							// Setting the title twice is done on purpose to clear the necessary space
							self.statusItem.title = firstBusMinutes.stringValue
							self.statusItem.title = firstBusMinutes.stringValue
//							self.firstBusLabel.title = "\(firstBusDirection): \(firstBusMinutes.stringValue) Minuten"
						}
					}

					// fill the menu with the other arriving busses
					for result in resultsArray {
						if let resultMinutes : NSNumber = result["arrivaltime"] as? NSNumber {
							if let resultDirection : String = result["direction"] as? String {
								self.statusMenu.addItemWithTitle("\(resultDirection): \(resultMinutes) Minuten", action: nil, keyEquivalent: "")
							}
						}
					}

				}
			}
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}

