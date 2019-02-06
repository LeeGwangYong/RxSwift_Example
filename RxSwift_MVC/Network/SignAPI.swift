//
//  SignAPI.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 05/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

enum SignAPI: EndPoint {
    // swiftlint:disable identifier_name
    case `in`(email: String, password: String)
    var baseURL: URL {
        guard let url = URL(string: "https://reqres.in/api") else {
            fatalError()
        }
        return url
    }
    
    var path: String {
        switch self {
        case .in:
            return "/login"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .in(email, password):
            return ["email": email,
                    "password": password]
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .in:
            return .post
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .in:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }

}
