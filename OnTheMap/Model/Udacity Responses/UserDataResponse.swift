//
//  UserDataResponse.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 11/09/2021.
//

import Foundation

struct UserDataResponse: Codable {
    
    let firstName: String
    let lastName: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case key
    }
}
