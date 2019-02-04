//
//  EndPoint.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]
protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headrs: HTTPHeaders? { get }
}

extension EndPoint {
    func urlRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path),
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 10.0)
        urlRequest.httpMethod = httpMethod.rawValue
        do {
            // 각 HTTPMethod에 대한 HeaderField의 이해가 부족함.
            // 추가적인 공부와 작업이 필요함.
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

        return urlRequest
    }
}
