//
//  TruefaceAPI.swift
//  FacePass
//
//  Created by Waseem Akram on 17/12/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import Alamofire

class TrueFaceAPI {
    class url {
        static let enrollURL = "https://api.trueface.ai/v1/enroll"
        static let collectionURL = "https://api.trueface.ai/v1/collection"
        static let trainURL = "https://api.trueface.ai/v1/train"
        static let identifierURL = "https://api.trueface.ai/v1/identify"
    }
    static let API_KEY = "Zv9ea4c8Fc3BBVkyXKxas1OadhRFqyPx9bGu0dEv"
    static let header: HTTPHeaders = ["x-api-key":API_KEY,"Content-Type": "application/json"]
    static let facePassCollectionID = "ahBzfmNodWlzcGRldGVjdG9ychcLEgpDb2xsZWN0aW9uGICAgNDRqMYIDA"
}
