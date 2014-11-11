//
//  AppDelegate.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 11/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var statusMenu: NSMenu!

	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let icon = NSImage(named: "statusIcon")
		icon?.setTemplate(true)

		statusItem.image = icon
		statusItem.menu = statusMenu
		statusItem.title = "5   " // Yeah, because extra spaces isn't shitty...
	}

	@IBAction func refreshClicked(sender: NSMenuItem) {
	}

	@IBAction func quitButtonPressed(sender: NSMenuItem) {
		NSApplication.sharedApplication().terminate(self)
	}
}

