//
//  ClosureMenuItem.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 18/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Cocoa

/**
*	Subclassing NSMenuItem to be able to set their actions with nice closures... Has the additional upside of settings the targets correctly
*/
class ClosureMenuItem: NSMenuItem {

	var actionClosure: () -> ()

	init(title: String, keyEquivalent: String, action: () -> ()) {
		self.actionClosure = action
		super.init(title: title, action: "action:", keyEquivalent: keyEquivalent)
		self.target = self
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func action(sender: NSMenuItem) {
		self.actionClosure()
	}
}
