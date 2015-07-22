//
//  DVBAPI.swift
//  catchmybus
//
//  Created by Kilian Költzsch on 11/05/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DVBAPI {

	/**
	Monitor request for a given stop. Returns data containing serving lines and a departure list amongst others.

	- parameter stopName:   Name of a stop
	- parameter completion: handler
	*/
	static func DMRequest(stopName: String, completion: (data: JSON?, err: NSError?) -> ()) {

		let url = NSURL(string: "http://efa.faplino.de/dvb/XML_DM_REQUEST")!
		let params = [
			"place_dm": "Dresden",
			"type_dm": "stop",
			"name_dm": stopName,
			"itdDateTimeDepArr": "dep",
			"mode": "direct",
			"outputFormat": "JSON"
		]

		Alamofire.request(.GET, URLString: url, parameters: params).responseJSON { (_, res, jsonData, err) in
			if err == nil && res?.statusCode == 200 {
				completion(data: JSON(jsonData!), err: nil)
			} else {
				completion(data: nil, err: err)
			}
		}
	}
}
