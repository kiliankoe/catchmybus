//
//  ConnectionManager.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 13/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import SwiftyJSON

private let _ConnectionManagerSharedInstace = ConnectionManager()

class ConnectionManager {

	// ConnectionManager is a singleton, accessible via ConnectionManager.shared()
	static func shared() -> ConnectionManager {
		return _ConnectionManagerSharedInstace
	}

	// MARK: - Properties

	internal var stopDict = [String: Int]()
	internal var notificationDict = [String: Int]()

	var connections = [Connection]()
	var selectedConnection: Connection? {
		get {
			return self.selectedConnection
		}
		set(newSelection) {
			self.deselectAll()
			newSelection!.selected = true
			self.selectedConnection = newSelection // is this needed?
		}
	}

	var selectedStop: String?
	// TODO: Should the ConnectionManager be keeping the list of stops as well?

	// MARK: -

	init () {
		loadDefaults()
	}

	/**
	Load internal stopDict, notificationDict and selectedStop from NSUserDefaults
	*/
	internal func loadDefaults() {
		stopDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(kStopDictKey) as! [String: Int]
		notificationDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(kNotificationDictKey) as! [String: Int]
		selectedStop = NSUserDefaults.standardUserDefaults().stringForKey(kSelectedStopKey)!
	}

	/**
	Save internal stopDict, notificationDict and selectedStop to NSUserDefaults
	*/
	internal func saveDefaults() {
		NSUserDefaults.standardUserDefaults().setObject(stopDict, forKey: kStopDictKey)
		NSUserDefaults.standardUserDefaults().setObject(notificationDict, forKey: kNotificationDictKey)
		NSUserDefaults.standardUserDefaults().setObject(selectedStop, forKey: kSelectedStopKey)

		NSUserDefaults.standardUserDefaults().synchronize()
	}

	// MARK: - Manage list of connections

	/**
	Delete all stored connections
	*/
	internal func nuke() {
		connections.removeAll(keepCapacity: false)
	}

	/**
	Set all connections' selected attribute to false
	*/
	internal func deselectAll() {
		for connection in connections {
			connection.selected = false
		}
	}

	// MARK: - Update Methods

	/**
	Update arrival countdowns for known connections and remove connections that lie in the past
	*/
	internal func updateConnectionCountdowns() {
		// Update arrival countdowns for currently known connections
		for connection in connections {
			connection.update()
		}

		// Remove connections that lie in the past
		connections = connections.filter { (c: Connection) -> Bool in
			return c.date.timeIntervalSinceNow > 0
		}
	}

	/**
	Make a call to DVBAPI to update list of connections

	- parameter completion: handler when new data has been stored in connection list, will not be called on error
	*/
	internal func updateConnections(completion: (err: NSError?) -> Void) {
		if let selectedStopName = selectedStop {
			DVBAPI.DMRequest(selectedStopName, completion: { (data, err) -> () in
				println(data)
				completion(err: nil)
			})
		} else {
			NSLog("Update error: No selected stop")
			completion(err: NSError(domain: "io.kilian.catchmybus", code: 0, userInfo: [NSLocalizedDescriptionKey: "Update error: No selected stop"]))
		}
	}
}
