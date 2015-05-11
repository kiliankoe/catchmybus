//
//  AboutWindowController.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import PFAboutWindow

class AboutWindowController {
	let aboutWindow: PFAboutWindowController

	init() {
		aboutWindow = PFAboutWindowController()

		aboutWindow.appName = "catchmybus"
		aboutWindow.appURL = NSURL(string: "http://catchmybus.kilian.io")
		aboutWindow.appCopyright = NSAttributedString(string: "Copyright (c) 2015 Kilian Koeltzsch")
		aboutWindow.appEULA = NSAttributedString(string: "The MIT License (MIT)\n\nCopyright (c) 2015 Kilian Koeltzsch\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
		aboutWindow.appCredits = NSAttributedString(string: "Thanks for help and tipps @h4llow3En\n\nName and idea shamelessly stolen from @hoodie")
	}

	func display() {
		aboutWindow.showWindow(nil)
		NSApp.activateIgnoringOtherApps(true)
	}
}
