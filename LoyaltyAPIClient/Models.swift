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
    let name, pass: String
}

// MARK: - UserInfoResponse
struct UserInfoResponse: Decodable {
    let id: Int
    let email, name, pass: String
}

// MARK: - AddCardRequest
struct AddCardRequest: Encodable {
    let name, color, code: String
}

// MARK: - CardResource
struct CardResource: Decodable {
    let id: Int
    let name, color, code: String
}

// MARK: - CardResource
struct CardPageResponse: Decodable {
    let count: Int
    let cards: [CardResource]
}

