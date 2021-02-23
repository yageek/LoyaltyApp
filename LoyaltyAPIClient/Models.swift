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
    let name, code: String
    let color: String?
}

// MARK: - CardResource
public struct CardResource: Decodable, Hashable {
    public init(id: Int, name: String, code: String, color: String?) {
        self.id = id
        self.name = name
        self.code = code
        self.color = color
    }

    public let id: Int
    public let name, code: String
    public let color: String?
}

// MARK: - CardResource
public struct CardPageResponse: Decodable {
    public init(count: Int, cards: [CardResource]) {
        self.count = count
        self.cards = cards
    }

    public let count: Int
    public let cards: [CardResource]
}

