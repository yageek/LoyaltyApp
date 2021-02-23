//
//  Services.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 22/02/2021.
//

import Foundation
import Combine
import RxSwift
import LoyaltyAPIClient

protocol APIClientService {
    func signIn(email: String, password: String) -> Single<()>
    func signUp(name: String, email: String, password: String) -> Single<()>
    func signOut() -> Single<()>
    func getAllLoyalties(offset: UInt, limit: UInt) -> Single<CardPageResponse>
}

protocol HasAPIClientService {
    var apiService: APIClientService { get }
}

// MARK: - Extension
struct APIClientStub: APIClientService {
    func getAllLoyalties(offset: UInt, limit: UInt) -> Single<CardPageResponse> {
        return .just(CardPageResponse(count: 20, cards: [CardResource(id: 0, name: "TEst", code: "1234", color: nil)]))
    }

    private struct StubError: Error { }
    let allSuccess: Bool
    func signOut() -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }

    func signIn(email: String, password: String) -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }

    func signUp(name: String, email: String, password: String) -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }
}
