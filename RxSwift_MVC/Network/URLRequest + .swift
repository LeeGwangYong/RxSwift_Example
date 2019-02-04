//
//  Encoder.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func encodeJSON(with parameters: Parameters) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            self.httpBody = jsonData
        } catch {
            throw NetworkError.encodingFailed
        }
        
        if self.value(forHTTPHeaderField: "Content-Type") == nil {
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
    
    mutating func encodeURL(with parameters: Parameters) throws {
        guard let url = self.url else { throw NetworkError.unknown }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            urlComponents.queryItems = parameters.map{ URLQueryItem(name: $0, value: "\($1)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) }
            
            self.url = urlComponents.url
        }
        
        if self.value(forHTTPHeaderField: "Content-Type") == nil {
            self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
    
    mutating func congifure(body: Parameters?, url: Parameters?, headers: HTTPHeaders?) throws {
        if body == nil && url == nil && headers == nil {
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            if let body = body, let url = url {
                try self.encodeURL(with: url)
                try self.encodeJSON(with: body)
            }
            
            if let headers = headers {
                headers.forEach{ self.setValue($1, forHTTPHeaderField: $0) }
            }
        }
    }
}
