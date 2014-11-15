//
//  ConnectionMenuItem.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 15/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Cocoa

class ConnectionMenuItem: NSMenuItem {

	let connection: Connection

	init (connection: Connection, title: String, action: Selector, keyEquivalent: String) {
		self.connection = connection
		super.init(title: title, action: action, keyEquivalent: keyEquivalent)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

}
