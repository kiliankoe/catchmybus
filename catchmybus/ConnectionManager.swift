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

							let line = result[0]
							let direction = result[1]
							var arrivalMinutes: Int
							if (result[2] == "") {
								arrivalMinutes = 0
							} else {
								arrivalMinutes = result[2].toInt()!
							}

							let connection = Connection(line: line, direction: direction, arrivalMinutes: arrivalMinutes)
							self.connections.append(connection)
						}

						// update UI only when everything has been pulled
						callback()
					}
			}
		} else {
			NSLog("Couldn't find the selected stop in stopDict. This is entirely the user's fault.")
		}
	}

	func clear() {
		connections.removeAll(keepCapacity: false)
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
