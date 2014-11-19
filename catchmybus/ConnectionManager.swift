//
//  ConnectionManager.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire

class ConnectionManager {

	var stopDict: Dictionary<String, Int> = ["Helmholtzstraße" : 3, "Zellescher Weg" : 8]
	var selectedStop = "Helmholtzstraße"

	var connections = [Connection]()
	// need something here, and I don't feel like checking for an optional on the other end
	var selectedConnection: Connection = Connection(line: "", direction: "", arrivalMinutes: 1337)

	func update(callback: () -> Void) {
		if let vz = stopDict[selectedStop] {
			let requestURL = "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?hst=\(cleanupURLString(selectedStop))&lim=30&vz=\(vz)"
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
		// filter out any connections that have already passed the current time
		connections.filter({(c: Connection) -> Bool in
			let currentDate = NSDate()
			if (currentDate.laterDate(c.arrivalDate) == c.arrivalDate) {
				return false
			} else {
				return true
			}
		})
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

}
