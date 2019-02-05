//
//  EndPoint.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

//https://github.com/ReactiveX/RxSwift/blob/master/RxCocoa/Foundation/URLSession%2BRx.swift
//https://medium.com/flawless-app-stories/writing-network-layer-in-swift-protocol-oriented-approach-4fa40ef1f908
//https://reqres.in

//HTTP Method와 Header에 대한 이해
//https://gist.github.com/jays1204/703297eb0da1facdc454
//https://developer.mozilla.org/ko/docs/Web/HTTP/Methods/POST

import Foundation

typealias HTTPHeaders = [String: String]
protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

extension EndPoint {
    func urlRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path),
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 10.0)
        urlRequest.httpMethod = httpMethod.rawValue
        do {
            if let parameters = parameters {
                switch httpMethod {
                case .get:
                    try URLParameterEncoder.encode(request: &urlRequest, parameters: parameters)
                case .post:
                    try JSONParameterEncoder.encode(request: &urlRequest, parameters: parameters)
                default:
                    break
                }
            } else {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
        
        if let headers = headers {
            headers.forEach{ urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        return urlRequest
    }
}
