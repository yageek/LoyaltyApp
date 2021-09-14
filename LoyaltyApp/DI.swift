//
//  DI.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 14/09/2021.
//

import Foundation
import LoyaltyAPIClient

struct AppDi: HasAPIClientService {
    static let shared = AppDi()
    var apiService: APIClientService = LoyaltyAPIClient()

}
