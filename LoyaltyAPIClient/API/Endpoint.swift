//
//  Endpoint.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation

enum Method {
    case get, post, put, delete

    var httpMethod: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}

protocol Endpoint {
    var method: Method { get }
    var baseHost: URL { get }
    var path: String { get }
    var params: [String: Any?] { get }
}



