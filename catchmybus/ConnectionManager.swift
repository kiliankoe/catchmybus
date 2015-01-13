//
//  ConnectionManager.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 13/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

class ConnectionManager {

	var stopDict: Dictionary<String, Int> = ["Helmholtzstraße": 1, "Zellescher Weg": 5, "Heinrich-Zille-Straße": 8, "Technische Universität": 1]
	var selectedStop = "Helmholtzstraße"

	func updateStopDict(newStopDict: Dictionary<String, Int>) {
		// TODO: I believe I should be implemented. Maybe fix that?
	}

	var connections = [Connection]()

	// need something here, and I don't feel like checking for an optional at the other end
	var selectedConnection: Connection = Connection(line: "", direction: "", arrivalMinutes: 1337)

	func update(callback: () -> Void) {
		// update arrival minutes for currently known connections
		for connection in connections {
			connection.update()
		}

		// clear out old connections that have passed the current time
		connections = connections.filter({(c: Connection) -> Bool in
			return c.arrivalDate.timeIntervalSinceNow > 0
		})

		// fetch new data
		var pretime = 0
		if (stopDict[selectedStop] != nil) {
			pretime = stopDict[selectedStop]!
		}
		var requestURL = NSURL(string: "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do")
		let requestParams = [
			"hst": selectedStop,
			"vz": "\(pretime)",
			"ort": "Dresden",
			"lim": "30"
		]
		requestURL = self.NSURLByAppendingQueryParameters(requestURL, queryParameters: requestParams)
		let requestTask = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) { (data, response, error) in
			if let output = (NSString(data: data, encoding: NSUTF8StringEncoding)) {
				var parseError: NSError?
				let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
				if let connectionList = parsedObject as? NSArray {
					if (connectionList.count > 0) {
						for connectionItem in connectionList {
							// transfer a single connection's array into its components
							let line = connectionItem[0] as String
							let direction = connectionItem[1] as String
							var arrivalMinutes: Int
							if (connectionItem[2] as String == "") {
								arrivalMinutes = 0
							} else {
								let arrivalMinutesString = connectionItem[2] as String
								arrivalMinutes = arrivalMinutesString.toInt()!
							}
							let newConnection = Connection(line: line, direction: direction, arrivalMinutes: arrivalMinutes)

							// Get the arrivaltime for the latest already known connection so that
							// only those with a later arrivaltime can bed added
							if let lastConnection = self.connections.last {
								let lastConnectionDate = lastConnection.arrivalDate
								if (newConnection.arrivalDate.laterDate(lastConnectionDate) == newConnection.arrivalDate) {
									// the date on this new connection is later than the one for the last
									// connection in the list
									// FIXME: This might result in a duplicate entry if it's only off by a little, possible fix below
									let dateDiff = lastConnection.arrivalDate.timeIntervalSinceDate(newConnection.arrivalDate)
									if (lastConnection.line != newConnection.line || lastConnection.direction != newConnection.direction || abs(dateDiff) > 90) {
										self.connections.append(newConnection)
									}
								}
							} else {
								// apparenlty self.connections is still empty
								self.connections.append(newConnection)
							}
						}
					}
					callback()
				}
			}
		}

		requestTask.resume()
	}

	func nuke() {
		connections.removeAll(keepCapacity: false)
	}

	func selectConnection(connectionToSelect: Connection) {
		for connection in connections {
			connection.selected = false
		}
		connectionToSelect.selected = true
		selectedConnection = connectionToSelect
	}

	// MARK: - Helper functions for NSURL

	func stringFromQueryParameters(queryParameters: Dictionary<String, String>) -> String {
		var parts: [String] = []
		for (name, value) in queryParameters {
			var part = NSString(format: "%@=%@",
				name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
				value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
			parts.append(part)
		}
		return "&".join(parts)
	}

	func NSURLByAppendingQueryParameters(URL: NSURL!, queryParameters: Dictionary<String, String>) -> NSURL {
		let URLString: NSString = NSString(format: "%@?%@", URL.absoluteString!, self.stringFromQueryParameters(queryParameters))
		return NSURL(string: URLString)!
	}

}
