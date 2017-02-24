//
//  NetworkManager.swift
//  TUHub
//
//  Created by Connor Crawford on 2/13/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkManager: NSObject {
    
    enum UserEndpoint: String {
        case grades = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/grades/"
        case courseOverview = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/overview/"
        case courseFullView = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/fullview/"
        case courseCalendarView = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/calendarview/"
        // case courseRoster = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/courses/roster/"
        // Nevermind, this endpoint doesn't work? It always gives invalid arguments error. Will investigate further.
    }
    
    enum Endpoint: String {
        case getUserInfo = "https://prd-mobile.temple.edu/banner-mobileserver/api/2.0/security/getUserInfo"
//        case 
    }
    
    typealias ResponseHandler = (JSON?, Error?) -> Void
    
//    static private(set) var shared: NetworkManager?
//    
//    private let username: String
//    private let password: String
//    
//    private init(username: String, password: String) {
//        self.username = username
//        self.password = password
//    }
//    
//    static func setSharedInstance(username: String, password: String) {
//        shared = NetworkManager(username: username, password: password)
//    }
//    
//    static func destroySharedInstance() {
//        NetworkManager.shared = nil
//    }
    
    static func request(fromEndpoint endpoint: Endpoint, _ responseHandler: ResponseHandler?) {
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, authenticateWith: nil, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: Endpoint, authenticateWith credential: Credential, _ responseHandler: ResponseHandler?) {
        NetworkManager.request(url: endpoint.rawValue, withTUID: nil, authenticateWith: credential, responseHandler)
    }
    
    static func request(fromEndpoint endpoint: UserEndpoint, withTUID tuID: String, authenticateWith credential: Credential, _ responseHandler: ResponseHandler?) {
        NetworkManager.request(url: endpoint.rawValue, withTUID: tuID, authenticateWith: nil, responseHandler)
    }
    
    private static func request(url: String, withTUID tuID: String?, authenticateWith credential: Credential?, _ responseHandler: ResponseHandler?) {
        
        
        
        // Generate HTTP Basic Auth header
        var headers: HTTPHeaders?
        if let credential = credential {
            headers = [:]
            if let authorizationHeader = Request.authorizationHeader(user: credential.username, password: credential.password) {
                headers![authorizationHeader.key] = authorizationHeader.value
            }
        }
        
        
        Alamofire.request(url + (tuID ?? ""), headers: headers)
            .responseJSON { (response) in
                // Log error if there is one
                if let error = response.error {
                    log.error(error)
                }
                
                // Retrieve JSON if available
                if let json = response.result.value {
                    let json = JSON(json)
                    responseHandler?(json, response.error)
                    return
                }
                
                responseHandler?(nil, response.error)
        }
    }
    
}
