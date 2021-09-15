//
//  LoyaltyAPIClient.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation

public final class LoyaltyAPIClient {

    public init() { }
    // MARK: - iVar | Concurrency
    let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "net.yageek.loyaltyAPIClient"
        queue.qualityOfService = .background
        return queue
    }()

    // MARK: - Helper
    @discardableResult func execute<Body: Encodable, ResponseBody: Decodable>(api: API, body: Body?, completion: @escaping (Result<ResponseBody?, Error>) -> Void)  -> CancellableRequest {
        let operation = RequestOperation(endpoint: api, body: body, completion: completion)
        operationQueue.addOperation(operation)
        return operation
    }

    // MARK: - User management
    @discardableResult public func signUp(email: String, password: String, name: String, completion: @escaping (Result<(), Error>) -> Void) -> CancellableRequest {
        let request = SignupRequest(email: email, name: name, pass: password)
        return self.execute(api: .signUp , body: request) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func signIn(email: String, password: String, completion: @escaping (Result<(), Error>) -> Void) -> CancellableRequest {
        let request = SigninRequest(email: email, pass: password)
        return self.execute(api: .signIn , body: request) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func signOut(completion: @escaping (Result<(), Error>) -> Void) -> CancellableRequest {
        let body: Int? = nil
        return self.execute(api: .signOut , body: body) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func getUserInfo(completion: @escaping (Result<UserInfoResponse, Error>) -> Void) -> CancellableRequest {
        let body: Int? = nil
        return self.execute(api: .getUserInfos , body: body) { (result: Result<UserInfoResponse?, Error>) in
            let converted: Result<UserInfoResponse, Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }

    @discardableResult public func getAllLoyalties(offset: Int, limit: Int, completion: @escaping (Result<CardPageResponse, Error>) -> Void) -> CancellableRequest {
        let body: Int? = nil
        return self.execute(api: .getLoyalties(limit: limit, offset: offset) , body: body) { (result: Result<CardPageResponse?, Error>) in
            let converted: Result<CardPageResponse, Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }

    @discardableResult public func addLoyalty(name: String, code: String, color: String?, completion: @escaping (Result<CardResource, Error>) -> Void) -> CancellableRequest {
        let body = CardData(name: name, code: code, color: color)
        return self.execute(api: .addLoyalty , body: body) { (result: Result<CardResource?, Error>) in
            let converted: Result<CardResource, Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }

    @discardableResult public func updateLoyalty(id: Int, name: String, code: String, color: String?, completion: @escaping (Result<CardResource, Error>) -> Void) -> CancellableRequest {
        let body = CardData(name: name, code: code, color: color)
        return self.execute(api: .updateLoyalty(id: id) , body: body) { (result: Result<CardResource?, Error>) in
            let converted: Result<CardResource, Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }

    @discardableResult public func searchLoyalty(byName name: String?, completion: @escaping (Result<[CardResource], Error>) -> Void) -> CancellableRequest {
        let body = SearchBody(name: name ?? "")
        return self.execute(api: .search , body: body) { (result: Result<[CardResource]?, Error>) in
            let converted: Result<[CardResource], Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }
}
