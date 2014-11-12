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

	var selectedStop = "Helmholtzstrasse"

	var numberOfStopsListed = 0

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

		// fake a refresh when starting
		refreshClicked(manualRefreshButtonLabel!)

		var timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: true)
	}

	func updateUI() {
		// let's fake this for now
		refreshClicked(manualRefreshButtonLabel!)
	}

	func cleanupURLString(dirty: String) -> String {
		var string: NSString = dirty
		string = string.stringByReplacingOccurrencesOfString(" ", withString: "")
		string = string.stringByReplacingOccurrencesOfString("ä", withString: "ae")
		string = string.stringByReplacingOccurrencesOfString("ö", withString: "oe")
		string = string.stringByReplacingOccurrencesOfString("ü", withString: "ue")
		string = string.stringByReplacingOccurrencesOfString("Ä", withString: "Ae")
		string = string.stringByReplacingOccurrencesOfString("Ö", withString: "Oe")
		string = string.stringByReplacingOccurrencesOfString("Ü", withString: "Ue")
		string = string.stringByReplacingOccurrencesOfString("ß", withString: "ss")

		return string as String
	}

	@IBAction func refreshClicked(sender: NSMenuItem) {
		let requestURL = "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?hst=\(selectedStop)&lim=5"
		Alamofire.request(.GET, requestURL)
			.responseJSON { (_, _, JSON, error) in
				if (error != nil) {
					return
				}

				let resultsArray : [[String]] = JSON as [[String]]
				if (resultsArray.count > 0) {
					let firstResult = resultsArray[0]

					// clear old entries
					for i in 0..<self.numberOfStopsListed {
						self.statusMenu.removeItemAtIndex(0)
					}
					self.numberOfStopsListed = 0

					// set the next bus' arrivaltime in the statusbar title
					var firstBusMinutes : String = firstResult[2]
					if (firstBusMinutes == "") {
						firstBusMinutes = "0"
					}
					let firstBusDirection : String = firstResult[1]
					// Setting the title twice is done on purpose to clear the necessary space
					self.statusItem.title = firstBusMinutes
					self.statusItem.title = firstBusMinutes

					// fill the menu with the other arriving busses
					var i = 0
					for result in resultsArray {
						var resultMinutes : String = result[2]
						if (resultMinutes == "") {
							resultMinutes = "0"
						}
						let resultDirection : String = result[1]
						let resultLine : String = result[0]

						self.statusMenu.insertItemWithTitle("\(resultLine) \(resultDirection): \(resultMinutes) Minuten", action: nil, keyEquivalent: "", atIndex: i)
						i++

						// save the amount of listed stops so these can be removed at the next refresh
						self.numberOfStopsListed++
					}
				}
			}
	}

	@IBAction func settingsButtonPressed(sender: NSMenuItem) {

	}
	
	@IBAction func selectStop(sender: NSMenuItem) {
		self.selectedStop = cleanupURLString(sender.title)
		for label in stopLabels {
			label.state = NSOffState
		}
		sender.state = NSOnState
		updateUI()
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}

