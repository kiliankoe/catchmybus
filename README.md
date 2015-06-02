#catchmybus

A simple little app that lives in the Mac's menubar and displays when the next bus or tram leaves the stop you specify (in Dresden, Germany).
You can also choose a specific bus or tram to be notified about when it's getting close.

The selection of custom stops is unfortunately not possible quite yet. It's coming :blush:

Runs on OS X 10.10 Yosemite.

## Download

Click [here](https://github.com/kiliankoe/catchmybus/releases/latest) for the latest release.

## Screenshot

![screenshot](./screenshot.png)

## Compiling

You'll need OS X 10.10 (oh-ess-ten-ten-ten), Xcode and Cocoapods. 

- Clone this project
- Run `pod install` in the project directory
- Open `catchmybus.xcworkspace` in Xcode
- Press Run

That didn't work? Please [tell me](https://github.com/kiliankoe/catchmybus/issues/new) about it.

## Looking for another city?

I've tried leaving all code making this specific to Dresden in `DVBAPI.swift`. Adjusting that to another providers API and data model is what you're going to have to do to get this working for elsewhere. 

Please tell me about it if you do so, I'd just love to see! I'm available to help if any issues arise. I'd also gladly accept pull request making catchmybus itself more versatile. Being able to change the city in the settings would be sweet!

## Credits

Name and idea shamelessly stolen from [hoodie/catch-my-bus](https://github.com/hoodie/catch-my-bus).

There's a very similar version to catchmybus built with Python and GTK if you're looking for something that will run on other systems. Check that out here: [devmeepo/catch-my-bus-python](https://github.com/devmeepo/catch-my-bus-python).
