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

enum UpdateError {
	case Server
	case Request
}

class DVBAPI {
	static func DMRequest(stopName: String, completion: (data: JSON?, err: UpdateError?) -> ()) {

		let url = NSURL(string: "http://efa.faplino.de/dvb/XML_DM_REQUEST")!
		let params = [
			"place_dm": "Dresden",
			"type_dm": "stop",
			"name_dm": stopName,
			"itdDateTimeDepArr": "dep",
			"mode": "direct",
			"outputFormat": "JSON"
		]

		Alamofire.request(.GET, url, parameters: params).responseJSON { (_, res, jsonData, err) in
			if err == nil && res?.statusCode == 200 {
				completion(data: JSON(jsonData!), err: nil)
			} else if err != nil && res?.statusCode == 200 {
				completion(data: nil, err: .Server)
			} else {
				completion(data: nil, err: .Request)
			}
		}
	}
}
