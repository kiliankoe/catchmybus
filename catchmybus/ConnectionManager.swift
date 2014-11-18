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
	var tmpConnections = [Connection]()

	func update(callback: () -> Void) {
		if let vz = stopDict[selectedStop] {
			let requestURL = "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?hst=\(cleanupURLString(selectedStop))&lim=30&vz=\(vz)"
			Alamofire.request(.GET, requestURL)
				.responseJSON { (_, _, JSON, error) in
					if (error != nil) {
						return
					}

					let resultsArray : [[String]] = JSON as [[String]]
					if (resultsArray.count > 0) {
						for result in resultsArray {

							// rip the current string array into single components
							let line = result[0]
							let direction = result[1]
							var arrivalMinutes: Int
							if (result[2] == "") {
								arrivalMinutes = 0
							} else {
								arrivalMinutes = result[2].toInt()!
							}
							let newConnection = Connection(line: line, direction: direction, arrivalMinutes: arrivalMinutes)
//							println("\(newConnection.line) \(newConnection.direction) - \(newConnection.arrivalMinutes)")

							// all of this just feels so dirty
							var numberOldConnections = self.connections.count
							var	numberNewConnections = 0
							var connectionAlreadyExists = false

							// make sure the very first connection on start is saved
							if (self.connections.isEmpty && self.tmpConnections.isEmpty) {
								numberNewConnections++
								self.tmpConnections.append(newConnection)
							}

							// loop through all known connections and check if they're already known or within 90 seconds of each other
							// if so they're not added again
							for connection in self.tmpConnections {
								numberNewConnections++
								let dateDiff = NSTimeInterval(connection.arrivalDate.timeIntervalSinceDate(newConnection.arrivalDate))
								if (connection.line == line && connection.direction == direction && abs(dateDiff) < 90) {
									connectionAlreadyExists = true
//									println("Not adding:")
//									println("\(connection.line) \(connection.direction) - \(connection.arrivalMinutes)")
									break
								}
							}

							// it really is a new connection, add it
							if (numberNewConnections >= numberOldConnections && !connectionAlreadyExists) {
								self.tmpConnections.append(newConnection)
							}
							numberNewConnections = 0
							connectionAlreadyExists = false
						}

						self.connections = self.tmpConnections
						self.tmpConnections.removeAll(keepCapacity: false)

//						println("\(self.connections.count) connections saved")

						// update UI only when everything has been pulled
						callback()
					}
			}
		} else {
			NSLog("Couldn't find the selected stop in stopDict. This is entirely the user's fault.")
		}
	}

	func clear() {
		// filter out any connections that have already passed the current time
		tmpConnections = connections.filter({(c: Connection) -> Bool in
			let currentDate = NSDate()
			if (currentDate.laterDate(c.arrivalDate) == c.arrivalDate) {
				return false
			} else {
				return true
			}
		})

		connections = tmpConnections
		tmpConnections.removeAll(keepCapacity: false)
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
