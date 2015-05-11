//
//  SettingsWindowController.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Cocoa
import IYLoginItem

class SettingsWindowController: NSWindowController {

	// MARK: - Outlets

	@IBOutlet weak var numRowsToShowLabel: NSTextField!
	@IBOutlet weak var numRowsToShowSlider: NSSlider!
	@IBOutlet weak var numRowsToShowDescriptionLabel: NSTextField!

	@IBOutlet weak var displayNotificationsCheckbox: NSButton!

	@IBOutlet weak var startAppAtLoginCheckbox: NSButton!

	// MARK: -

    override func windowDidLoad() {
        super.windowDidLoad()

		let numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey(kNumRowsToShowKey)
		numRowsToShowLabel.integerValue = numRowsToShow
		numRowsToShowSlider.integerValue = numRowsToShow

		let shouldDisplayNotifications = NSUserDefaults.standardUserDefaults().boolForKey(kShouldDisplayNotifications)
		if shouldDisplayNotifications {
			displayNotificationsCheckbox.state = NSOnState
		} else {
			displayNotificationsCheckbox.state = NSOffState
		}

		if NSBundle.mainBundle().isLoginItem() {
			startAppAtLoginCheckbox.state = NSOnState
		} else {
			startAppAtLoginCheckbox.state = NSOffState
		}

		// TODO: Use NSLocalizedStrings to update labels for all UI elements

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	internal func display() {
		self.window?.makeKeyAndOrderFront(nil)
		NSApp.activateIgnoringOtherApps(true)
	}

	// MARK: - IBActions

	@IBAction func numRowsToShowSliderValueChanged(sender: NSSlider) {
		numRowsToShowLabel.integerValue = sender.integerValue
		NSUserDefaults.standardUserDefaults().setObject(sender.integerValue, forKey: kNumRowsToShowKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		NSNotificationCenter.defaultCenter().postNotificationName(kUpdatedNumRowsToShowNotification, object: nil)
	}

	@IBAction func displayNotificationsCheckboxClicked(sender: NSButton) {
		if sender.state == NSOnState {
			NSUserDefaults.standardUserDefaults().setObject(true, forKey: kShouldDisplayNotifications)
		} else {
			NSUserDefaults.standardUserDefaults().setObject(false, forKey: kShouldDisplayNotifications)
		}
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	@IBAction func startAppAtLoginCheckboxClicked(sender: NSButton) {
		if sender.state == NSOnState {
			NSBundle.mainBundle().addToLoginItems()
			// TODO: Check if this changes state when clicked
		} else {
			NSBundle.mainBundle().removeFromLoginItems()
		}
	}
    
}
