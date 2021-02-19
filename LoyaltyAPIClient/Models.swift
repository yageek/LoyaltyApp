//
//  Models.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation

// MARK: - SignupRequest
struct SignupRequest: Encodable {
    let email, name, pass: String
}

// MARK: - SignInRequest
struct SigninRequest: Encodable {
    let email, pass: String
}

// MARK: - UserInfoResponse
public struct UserInfoResponse: Decodable {
    public let id: Int
    public let email, name, pass: String
}

// MARK: - CardData
struct CardData: Encodable {
    let name, color, code: String
}

// MARK: - CardResource
public struct CardResource: Decodable, Hashable {
    public let id: Int
    public let name, color, code: String
}

// MARK: - CardResource
public struct CardPageResponse: Decodable {
    public let count: Int
    public let cards: [CardResource]
}

