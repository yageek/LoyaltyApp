//
//  Providers.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 22/02/2021.
//

import RxSwift

import LoyaltyAPIClient
extension LoyaltyAPIClient: APIClientService {
    func signIn(email: String, password: String) -> Single<()> {
        return Single.create { (obs) -> Disposable in

            let cancellable = self.signIn(email: email, password: password) { (result) in
                obs(result)
            }

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func signUp(name: String, email: String, password: String) -> Single<()> {
        return Single.create { (obs) -> Disposable in

            let cancellable = self.signUp(email: email, password: password, name: name) { (result) in
                obs(result)
            }

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func signOut() -> Single<()> {
        return Single.create { (obs) -> Disposable in

            let cancellable = self.signOut() { (result) in
                obs(result)
            }

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }

    func getAllLoyalties(offset: UInt, limit: UInt) -> Single<CardPageResponse> {
        return Single.create { (obs) -> Disposable in

            let cancellable = self.getAllLoyalties(offset: offset, limit: limit) { (result) in
                obs(result)
            }

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}
