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
    func signUp(email: String, password: String, name: String) -> Single<()>
    func signOut() -> Single<()>
    func getUserInfo() -> Single<UserInfoResponse>
    func getAllLoyalties(offset: Int, limit: Int) -> Single<CardPageResponse>
    func addLoyalty(name: String, code: String, color: String?) -> Single<CardResource>
    func updateLoyalty(id: Int, name: String, code: String, color: String?) -> Single<CardResource>
    func searchLoyalty(byName name: String?) -> Single<[CardResource]>
}

protocol HasAPIClientService {
    var apiService: APIClientService { get }
}

// MARK: - Extension
struct APIClientStub: APIClientService {
    func getUserInfo() -> Single<UserInfoResponse> {
        if allSuccess {
            return .just(UserInfoResponse(id: 0, email: "some@mail.com", name: "John Appleseed", pass: "secret1234"))
        } else {
            return .error(StubError())
        }
    }

    func getAllLoyalties(offset: Int, limit: Int) -> Single<CardPageResponse> {
        if allSuccess {
            let cardresource = CardResource(id: 0, name: "Hello", code: "1234", color: "#fffff")
            return Single.just(CardPageResponse(count: 1, cards: [cardresource]))
        } else {
            return .error(StubError())
        }
    }

    func addLoyalty(name: String, code: String, color: String?) -> Single<CardResource> {
        if allSuccess {
            return Single.just(CardResource(id: 0, name: "Hello", code: "1234", color: "#fffff"))
        } else {
            return .error(StubError())
        }
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

    func signUp(email: String, password: String, name: String) -> Single<()> {
        if allSuccess {
            return Single.just(())
        } else {
            return Single.error(StubError())
        }
    }

    func updateLoyalty(id: Int, name: String, code: String, color: String?) -> Single<CardResource> {
        if allSuccess {
            return .just(CardResource(id: 0, name: "John AppleSeed", code: "1234", color: nil))
        } else {
            return .error(StubError())
        }
    }

    func searchLoyalty(byName name: String?) -> Single<[CardResource]> {
        if allSuccess {
            return .just([CardResource(id: 0, name: "Carte 1", code: "123", color: nil)])
        } else {
            return .error(StubError())
        }
    }
}

extension LoyaltyAPIClient: APIClientService {
    func getUserInfo() -> Single<UserInfoResponse> {
        return Single.create { single in

            let task = self.getUserInfo { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func getAllLoyalties(offset: Int, limit: Int) -> Single<CardPageResponse> {
        return Single.create { single in

            let task = self.getAllLoyalties(offset: offset, limit: limit) { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }

    }

    func addLoyalty(name: String, code: String, color: String?) -> Single<CardResource> {

        return Single.create { single in
            let task = self.addLoyalty(name: name, code: code, color: color) { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func signIn(email: String, password: String) -> Single<()> {
        return Single.create { single in
            let task =  self.signIn(email: email, password: password) { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func signUp(email: String, password: String, name: String) -> Single<()> {
        return Single.create { single in
            let task = self.signUp(email: email, password: password, name: name) { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }


    }

    func signOut() -> Single<()> {
        return Single.create { single in
            let task = self.signOut { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func updateLoyalty(id: Int, name: String, code: String, color: String?) -> Single<CardResource> {
        return Single.create { single in
            let task = self.updateLoyalty(id: id, name: name, code: code, color: color) { result in
                single(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func searchLoyalty(byName name: String?) -> Single<[CardResource]> {
        return Single.create { obs in

            let task = self.searchLoyalty(byName: name) { result in
                obs(result)
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
