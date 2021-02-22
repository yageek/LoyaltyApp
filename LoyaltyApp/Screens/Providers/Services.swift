//
//  Services.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 22/02/2021.
//

import Foundation
import Combine
import LoyaltyAPIClient
import RxSwift

protocol APIClientService: RxAPIClientService {
    func signIn(email: String, password: String) -> Future<(), Swift.Error>
    func signOut() -> Future<(), Error>
}

protocol RxAPIClientService {
    func rx_signIn(email: String, password: String) -> Single<()>
    func rx_signOut() -> Single<()>
}

protocol HasAPIClientService {
    var apiService: APIClientService { get }
}

// MARK: - Extension
struct APIClientStub: APIClientService, RxAPIClientService {
    private struct StubError: Error { }

    func signIn(email: String, password: String) -> Future<(), Error> {
            return Future { (obs) in
                if allSuccess {
                    obs(.success(()))
                } else {
                    obs(.failure(StubError()))
                }
            }
    }

    let allSuccess: Bool
    func signOut() -> Future<(), Error> {
        return Future { (obs) in
            if allSuccess {
                obs(.success(()))
            } else {
                obs(.failure(StubError()))
            }
        }
    }

    func rx_signOut() -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }

    func rx_signIn(email: String, password: String) -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }
}
