//
//  Connection.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Connection {

	let line: String
	let direction: String
	let arrivalMinutes: Int
	let arrivalTime: NSDate

	init (line: String, direction: String, arrivalMinutes: Int) {
		self.line = line
		self.direction = direction
		self.arrivalMinutes = arrivalMinutes
		self.arrivalTime = NSDate(timeIntervalSinceNow: NSTimeInterval(60 * arrivalMinutes))
	}

	func toString() -> String {
		// NSDate.dateWithCalendarFormat is actually deprecated as of OS X 10.10
		// use .descriptionWithLocale instead
		let dateformat = "%H:%M"
		let timezone = NSTimeZone(abbreviation: "CEST")

		if (arrivalMinutes > 59) {
			let hours = arrivalMinutes / 60
			let minutes = arrivalMinutes % 60
			return "\(line) \(direction): \(hours)h \(minutes) Minuten - \(arrivalTime.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		} else {
			return "\(line) \(direction): \(arrivalMinutes) Minuten - \(arrivalTime.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		}
	}

}
