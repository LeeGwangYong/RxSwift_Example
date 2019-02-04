//
//  APIRouter.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation
import RxSwift

typealias RouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
protocol RouterProtocol {
    func request(from route: EndPoint) throws -> URLRequest
}

class Router: RouterProtocol {
    func request(from route: EndPoint) throws -> URLRequest {
        var urlRequest = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 10.0)
        urlRequest.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request(let bodyParameters, let urlParameters, let headers):
                try urlRequest.congifure(body: bodyParameters, url: urlParameters, headers: headers)
            case .download, .upload:
                throw NetworkError.unknown
            }
        } catch {
            throw error
        }
        return urlRequest
    }
}
