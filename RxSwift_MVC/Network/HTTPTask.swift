//
//  HTTPTask.swift
//  RxSwift_MVC
//
//  Created by 이광용 on 04/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]
enum HTTPTask {
    case request
    case download
    case upload
}
