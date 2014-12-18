//
//  ConnectionManager.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire

// Easy way of getting a URL fit version of a string from itself
private extension String {
	var URLEscapedString: String {
		return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
	}
}

class ConnectionManager {

	var stopDict: Dictionary<String, Int> = ["Helmholtzstraße" : 1, "Zellescher Weg" : 5, "Heinrich-Zille-Straße" : 8, "Technische Universität" : 1]
	var selectedStop = "Helmholtzstraße"

	var connections = [Connection]()
	// need something here, and I don't feel like checking for an optional on the other end
	var selectedConnection: Connection = Connection(line: "", direction: "", arrivalMinutes: 1337)

	func update(callback: () -> Void) {
		if let vz = stopDict[selectedStop] {
			let requestURL = "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?hst=\(selectedStop.URLEscapedString))&lim=30&vz=\(vz)"
//			NSLog(requestURL)
			Alamofire.request(.GET, requestURL)
				.responseJSON { (_, _, JSON, error) in
					if (error != nil) {
						return
					}

					let resultsArray : [[String]] = JSON as [[String]]
					if (resultsArray.count > 0) {
						for result in resultsArray {

							// rip a single connection's string array into its single components
							let line = result[0]
							let direction = result[1]
							var arrivalMinutes: Int
							if (result[2] == "") {
								arrivalMinutes = 0
							} else {
								arrivalMinutes = result[2].toInt()!
							}
							let newConnection = Connection(line: line, direction: direction, arrivalMinutes: arrivalMinutes)

							// Cycle through all previously known connections to see if this one already exists.
							// For this the arrivaldates are compared and two connections are declared identical
							// if all their data matches and the arrivaldates are within 90 seconds of another.
							var i = 0
							for connection in self.connections {
								i++
								let dateDiff = connection.arrivalDate.timeIntervalSinceDate(newConnection.arrivalDate)
								if (connection.line == newConnection.line && connection.direction == newConnection.direction && abs(dateDiff) < 90) {
									break
								}
							}

							if (i == self.connections.count || self.connections.count == 0) {
								self.connections.append(newConnection)
							}
						}

						callback()
					}
			}
		} else {
			NSLog("Couldn't find the selected stop in stopDict. This is entirely the user's fault.")
		}

		// update the arrivalminutes for connections that are not new
		for connection in connections {
			let currentDate = NSDate()
			connection.update(currentDate)
		}
	}

	func clear() {
		// filter out any connections that have already passed the vz time
		if let vz = stopDict[selectedStop] {
			connections = connections.filter({(c: Connection) -> Bool in
				let vzTime = NSDate(timeIntervalSinceNow: NSTimeInterval(vz * 60))
				if (vzTime.laterDate(c.arrivalDate) == c.arrivalDate) {
					return true
				} else {
					return false
				}
			})
		}
	}

	func nuke() {
		connections.removeAll(keepCapacity: false)
	}

	func selectConnection(c: Connection) {
		for connection in connections {
			connection.selected = false
		}
		c.selected = true
		selectedConnection = c
	}

}
