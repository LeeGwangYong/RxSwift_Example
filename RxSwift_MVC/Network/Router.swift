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
    func request(from endPoint: EndPoint) throws -> URLRequest
}

class Router: RouterProtocol {
    static let shared = Router()
    func request(from endPoint: EndPoint) throws -> URLRequest {
        do {
            return try endPoint.urlRequest()
        } catch {
            throw error
        }
    }
}

extension Router: ReactiveCompatible {}

extension URLSession {
    func request(from endPoint: EndPoint) throws -> URLRequest {
        do {
            return try endPoint.urlRequest()
        } catch let error {
            throw error
        }
    }
}

extension Reactive where Base: URLSession {
    func response(from endPoint: EndPoint) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return Observable.create { observer in
            
            var request: URLRequest!
            do {
                request = try self.base.request(from: endPoint)
            } catch let error {
                observer.on(.error(error))
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let response = response, let data = data else {
                    observer.on(.error(error ?? NetworkError.unknown))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(error ?? NetworkError.none(response: response)))
                    return
                }
                
                observer.on(.next((httpResponse, data)))
                observer.on(.completed)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func data(from endPoint: EndPoint) -> Observable<Data> {
        return self.response(from: endPoint).map{
            switch $0.response.statusCode {
            case 200..<300:
                return $0.data
            default:
                throw NetworkError.requestFailed(response: $0.response, data: $0.data)
            }
        }
    }
    
    func json(from endPoint: EndPoint, options: JSONSerialization.ReadingOptions = []) -> Observable<Any> {
        return self.data(from: endPoint).map {
            do {
                return try JSONSerialization.jsonObject(with: $0, options: options)
            } catch let error {
                throw NetworkError.deserialization(error: error)
            }
        }
    }
}
