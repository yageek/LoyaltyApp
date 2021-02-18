//
//  API.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation


enum API {
    case signIn(user: String, password: String)
    case signUp(name: String, user: String, password: String)
    case signOut
    case addLoyalty(name: String, code: String, color: String?)
    case updateLoyalty(name: String, code: String, color: String?)
    case deleteLoyalty(id: Int)
}
