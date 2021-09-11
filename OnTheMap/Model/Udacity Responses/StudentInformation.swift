//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 07/09/2021.
//

import Foundation

struct StudentInformation: Codable {
    
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let uniqueKey: String
    let objectID: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "firstName"
        case lastName = "lastName"
        case latitude = "latitude"
        case longitude = "longitude"
        case mapString = "mapString"
        case mediaURL = "mediaURL"
        case uniqueKey = "uniqueKey"
        case objectID = "objectId"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}
