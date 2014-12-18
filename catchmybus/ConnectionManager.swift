//
//  ConnectionManager.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation

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
		if let pretime = stopDict[selectedStop] {
			var requestURL = NSURL(string: "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do")
			let requestParams = [
				"hst": selectedStop,
				"vz":  "\(pretime)",
				"ort": "Dresden",
				"lim": "10"
			]
			requestURL = self.NSURLByAppendingQueryParameters(requestURL, queryParameters: requestParams)
			let requestTask = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) { (data, response, error) in
				if let output = (NSString(data: data, encoding: NSUTF8StringEncoding)) {
					var parseError: NSError?
					let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,options: NSJSONReadingOptions.AllowFragments,error:&parseError)
					if let connectionList = parsedObject as? NSArray {
						if (connectionList.count > 0) {
							for connectionItem in connectionList {
								// rip a single connection's array into its single components
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
						}

						callback()
					}
				}
			}

			requestTask.resume()

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

	// Helper Functions for working with NSURLs and Params.

	func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
		var parts: [String] = []
		for (name, value) in queryParameters {
			var part = NSString(format: "%@=%@",
				name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
				value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
			parts.append(part)
		}
		return "&".join(parts)
	}

	func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
		let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString!, self.stringFromQueryParameters(queryParameters))
		return NSURL(string: URLString)!
	}

}
