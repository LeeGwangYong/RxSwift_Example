//
//  Encoder.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

protocol ParameterEncoder {
    static func encode(request: inout URLRequest, parameters: Parameters) throws
}
class JSONParameterEncoder: ParameterEncoder {
    static func encode(request: inout URLRequest, parameters: Parameters) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            throw NetworkError.encodingFailed
        }
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}

class URLParameterEncoder: ParameterEncoder {
    static func encode(request: inout URLRequest, parameters: Parameters) throws {
        guard let url = request.url else { throw NetworkError.unknown }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            urlComponents.queryItems =
                parameters.map{ URLQueryItem(name: $0, value: "\($1)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) }
            request.url = urlComponents.url
        }
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
