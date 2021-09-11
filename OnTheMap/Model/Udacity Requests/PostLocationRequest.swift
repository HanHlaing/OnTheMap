//
//  PostLocationRequest.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 11/09/2021.
//

import Foundation

struct PostLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
