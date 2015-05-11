//
//  Connection.swift
//  catchmybus
//
//  Created by Kilian Koeltzsch on 14/11/14.
//  Copyright (c) 2014 Kilian Koeltzsch. All rights reserved.
//

import Foundation

class Connection {

	let id: Int
	let line: String
	let direction: String
	var countdown: Int
	let date: NSDate

	var selected = false

	init (id: Int, line: String, direction: String, countdown: Int) {
		self.id = id
		self.line = line
		self.direction = direction
		self.countdown = countdown
		self.date = NSDate(timeIntervalSinceNow: NSTimeInterval(60 * countdown))
	}

	func update() {
		countdown = Int(date.timeIntervalSinceNow) / 60
	}

	func toString() -> String {
		// NSDate.dateWithCalendarFormat is actually deprecated as of OS X 10.10
		// TODO: use .descriptionWithLocale instead
		let dateformat = "%H:%M"
		let timezone = NSTimeZone(abbreviation: "CEST")

		if (countdown > 59) {
			let hours = countdown / 60
			let minutes = countdown % 60
			if (minutes == 0) {
				return "\(line) \(direction): \(hours) Stunden - \(date.dateWithCalendarFormat(dateformat, timeZone: timezone))"
			} else {
				return "\(line) \(direction): \(hours)h \(minutes) Minuten - \(date.dateWithCalendarFormat(dateformat, timeZone: timezone))"
			}
		} else if (countdown == 0) {
			return "\(line) \(direction): Jetzt - \(date.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		} else {
			return "\(line) \(direction): \(countdown) Minuten - \(date.dateWithCalendarFormat(dateformat, timeZone: timezone))"
		}
	}

}
