//
//  Connection.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation

class Connection {

	let line: String
	let direction: String
	var arrivalMinutes: Int
	let arrivalDate: NSDate

	var selected = false

	init (line: String, direction: String, arrivalMinutes: Int) {
		self.line = line
		self.direction = direction
		self.arrivalMinutes = arrivalMinutes
		self.arrivalDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60 * arrivalMinutes))
	}

	func update() {
		arrivalMinutes = Int(arrivalDate.timeIntervalSinceNow) / 60
	}

	func toString() -> String {
		// NSDate.dateWithCalendarFormat is actually deprecated as of OS X 10.10
		// TODO: use .descriptionWithLocale instead
		let dateformat = "%H:%M"
		let timezone = NSTimeZone(abbreviation: "CEST")

		if (arrivalMinutes > 59) {
			let hours = arrivalMinutes / 60
			let minutes = arrivalMinutes % 60
			if (minutes == 0) {
				return "\(line) \(direction): \(hours) Stunden - \(arrivalDate.dateWithCalendarFormat(dateformat, timeZone: timezone))"
			} else {
				return "\(line) \(direction): \(hours)h \(minutes) Minuten - \(arrivalDate.dateWithCalendarFormat(dateformat, timeZone: timezone))"
			}
		} else if (arrivalMinutes == 0) {
			return "\(line) \(direction): Jetzt - \(arrivalDate.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		} else {
			return "\(line) \(direction): \(arrivalMinutes) Minuten - \(arrivalDate.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		}
	}

}
