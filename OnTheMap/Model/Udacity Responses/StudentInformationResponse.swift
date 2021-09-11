//
//  StudentLocationsResponse.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 07/09/2021.
//

import Foundation

struct StudentInformationResponse: Codable {
    
    let results: [StudentInformation]?
    
    enum CodingKeys: String,CodingKey {
        case results = "results"
    }
}
