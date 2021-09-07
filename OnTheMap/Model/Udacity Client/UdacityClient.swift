//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 06/09/2021.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var accountId = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case createSessionId
        
        var urlString: String {
            switch self {
            case .createSessionId: return Endpoints.base + "session"
                
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data,response, error) in
            guard let data = data else {
                completion(nil,error)
                return
            }
            
            // Result need to remove first 5 character to be able to JSON Decode it
            let newData = data.subdata(in: (5..<data.count))
            let decoder = JSONDecoder()
            do {
                
                let responseObject = try decoder.decode(responseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func createSessionId(email: String, password:String, completion: @escaping (Bool, Error?) -> Void) {
        
        
        let body = LoginRequest(udacity: Udacity(username: email, password: password))
       
        taskForPOSTRequest(url: Endpoints.createSessionId.url,responseType: LoginResponse.self, body: body){ response,error in
            
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.accountId = response.account.key
                DispatchQueue.main.async {
                    completion(true,nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false,error)
                }
            }
        }
    }
}
