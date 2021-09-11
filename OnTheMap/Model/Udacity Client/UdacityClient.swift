//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Han Hlaing Moe on 06/09/2021.
//

import Foundation

class UdacityClient {
    
    // MARK: - Auth
    
    struct Auth {
        static var accountId = ""
        static var sessionId = ""
    }
    
    // MARK: - Endpoints
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1/"
        static let baseLocation = base + "StudentLocation"
        
        case createSessionId
        case getStudentLocations
        case getSingleStudentLocation(String)
        case getUserData(String)
        case addPin
        case updatePin(String)
        case logOut
        
        var urlString: String {
            
            switch self {
            case .createSessionId, .logOut: return Endpoints.base + "session"
            case .getStudentLocations: return Endpoints.baseLocation + "?limit=100&skip=0&order=-updatedAt"
            case .getSingleStudentLocation(let acccountId): return  Endpoints.baseLocation + "?uniqueKey=\(acccountId)"
            case .getUserData(let accountId): return Endpoints.base + "users/\(accountId)"
            case .addPin: return Endpoints.baseLocation
            case .updatePin(let objectId): return Endpoints.baseLocation + "/\(objectId)"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    // MARK: - Custom Requests and Responses
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(isUserDetail: Bool, url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let newData = isUserDetail ? data.subdata(in: (5..<data.count)): data
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
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
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(isCreateSession: Bool, url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
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
            let newData = isCreateSession ? data.subdata(in: (5..<data.count)): data
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
    
    // MARK: - Udacity API Requests and Responses
    
    class func createSessionId(email: String, password:String, completion: @escaping (Bool, Error?) -> Void) {
        
        
        let body = LoginRequest(udacity: Udacity(username: email, password: password))
        
        taskForPOSTRequest(isCreateSession: true, url: Endpoints.createSessionId.url, responseType: LoginResponse.self, body: body){ response,error in
            
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.accountId = response.account.key
                completion(true,nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    class func getStudentLocation(singleStudent: Bool, completion: @escaping (Bool,[StudentInformation]?, Error?) -> Void){
        
        let url = singleStudent ? Endpoints.getSingleStudentLocation(Auth.accountId).url:Endpoints.getStudentLocations.url
        
        taskForGETRequest(isUserDetail: false, url: url, responseType: StudentInformationResponse.self){ response, error in
            
            if let response = response {
                completion(singleStudent,response.results,nil)
            } else {
                completion(singleStudent,nil,error)
            }
        }
    }
    
    class func getUserData(completion: @escaping (UserDataResponse?, Error?) -> Void) {
        
        let url = Endpoints.getUserData(Auth.accountId).url
        taskForGETRequest(isUserDetail: true, url: url, responseType: UserDataResponse.self){ response, error in
            
            if let response = response {
                completion(response,nil)
            } else {
                completion(nil,error)
            }
        }
    }
    
    // Post Student Location
    class func postStudentLoaction(postLocation: PostLocationRequest, completion: @escaping (PostLocationResponse?, Error?) -> Void) {
        
        taskForPOSTRequest(isCreateSession: false, url: Endpoints.addPin.url, responseType: PostLocationResponse.self, body: postLocation){ response,error in
            
            if let response = response {
                completion(response,nil)
            } else {
                completion(nil,error)
            }
        }
    }
    
    class func putStudentLocation(objectID: String, postLocation: PostLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.updatePin(objectID).url)
        
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = postLocation
        let encoder = JSONEncoder()
        request.httpBody = try! encoder.encode(body)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    return completion(false, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let responseObj = try decoder.decode(PostLocationResponse.self, from: data)
                DispatchQueue.main.async {
                     print("\(responseObj)")
                     completion(true, nil)
                }
                
            }
            catch {
                // error
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
        task.resume()
    
    }
    
    class func logout(completionHandler: @escaping (Bool, Error?)->Void){
        var request = URLRequest(url: Endpoints.logOut.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard data != nil else{
              //cannot delete session
              DispatchQueue.main.async {
                  completionHandler(false, error)
              }
              return
          }
            DispatchQueue.main.async {
                completionHandler(true, nil)
            }
        }
        task.resume()
    }
}
