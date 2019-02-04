//
//  NetworkError.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case unknown
    case encodingFailed
    case none(response: URLResponse)
    case requestFailed(response: HTTPURLResponse, data: Data?)
    case deserialization(error: Error)
}

extension NetworkError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error has occurred."
        case .encodingFailed:
            return "Encoding is failed"
        case let .none(response):
            return "Response is not NSHTTPURLResponse `\(response)`."
        case let .requestFailed(response, _):
            return "HTTP request failed with `\(response.statusCode)`."
        case let .deserialization(error):
            return "Error during deserialization of the response: \(error)"
        }
    }
}
