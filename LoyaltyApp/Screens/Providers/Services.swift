//
//  Services.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 22/02/2021.
//

import Foundation
import Combine
import RxSwift

protocol APIClientService {
    func signIn(email: String, password: String) -> Single<()>
    func signUp(name: String, email: String, password: String) -> Single<()>
    func signOut() -> Single<()>
}

protocol HasAPIClientService {
    var apiService: APIClientService { get }
}

// MARK: - Extension
struct APIClientStub: APIClientService {
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
