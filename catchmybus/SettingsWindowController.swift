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
		NSLog("Settings window did load")

		let numRowsToShow = NSUserDefaults.standardUserDefaults().integerForKey(kNumRowsToShowKey)
		numRowsToShowLabel.integerValue = numRowsToShow
		numRowsToShowSlider.integerValue = numRowsToShow

		let shouldDisplayNotifications = NSUserDefaults.standardUserDefaults().boolForKey(kShouldDisplayNotifications)
		displayNotificationsCheckbox.state = shouldDisplayNotifications ? NSOnState : NSOffState

		startAppAtLoginCheckbox.state = NSBundle.mainBundle().isLoginItem() ? NSOnState : NSOffState

		// TODO: Use NSLocalizedStrings to update labels for all UI elements

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	internal func display() {
		// FIXME: This isn't working. Interestingly enough the window is also not opened when I set it to be displayed at launch in the xib. Something's not right.
		self.window?.makeKeyAndOrderFront(nil)
//		self.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
		NSLog("Settings window displaying")
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
