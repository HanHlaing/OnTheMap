//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 06/09/2021.
//

import Foundation

struct LoginRequest: Codable {
    
    let udacity : Udacity
    
    enum CodingKeys: String, CodingKey {
        case udacity
    }
}

struct Udacity : Codable {
    
    let username : String
    let password : String

    enum CodingKeys: String, CodingKey {

        case username
        case password
    }
}
