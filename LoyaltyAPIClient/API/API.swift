//
//  API.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation

enum API {
    case signIn
    case signUp
    case signOut
    case addLoyalty
    case updateLoyalty(id: Int)
    case deleteLoyalty(id: Int)
    case getLoyalties(limit: Int, offset: Int)
    case getUserInfos
}

let devBaseHost = URL(string: "http://localhost:8000")!

extension API: Endpoint {
    var method: Method {
        switch self {

        case .signIn, .signOut, .signUp:
            return .post
        case .addLoyalty, .updateLoyalty:
            return .put
        case .deleteLoyalty:
            return .delete
        case .getLoyalties, .getUserInfos:
            return .get
        }
    }

    var baseHost: URL {
        return devBaseHost
    }

    var path: String {
        switch self {
        case .signIn:
            return "signin"
        case .signUp:
            return "signup"
        case .signOut:
            return "signout"
        case .addLoyalty, .getLoyalties:
            return "loyalties"
        case .updateLoyalty(let id):
            return "loyalties/\(id)"
        case .deleteLoyalty(let id):
            return "loyalties/\(id)"
        case .getUserInfos:
            return "userinfo"
        }
    }

    var params: [String : Any?] {
        switch self {
        case .signIn, .signOut, .signUp, .addLoyalty, .deleteLoyalty, .getUserInfos, .updateLoyalty:
            return [:]
        case .getLoyalties(let limit, let offet):
            return ["limit": limit, "offset": offet]
        }
    }

    var responseFormat: ResponseFormat {
        switch self {

        case .signIn:
            return .text
        case .signUp:
            return .text
        case .signOut:
            return .text
        case .addLoyalty:
            return .json
        case .updateLoyalty:
            return .text
        case .deleteLoyalty:
            return .text
        case .getLoyalties:
            return .json
        case .getUserInfos:
            return .json
        }
    }
}
