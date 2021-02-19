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
    @discardableResult func execute<Body: Encodable, ResponseBody: Decodable>(api: API, body: Body?, completion: @escaping (Result<ResponseBody?, Error>) -> Void)  -> CancelableRequest {
        let operation = RequestOperation(endpoint: api, body: body, completion: completion)
        operationQueue.addOperation(operation)
        return operation
    }

    // MARK: - User management
    @discardableResult public func signUp(email: String, password: String, name: String, completion: @escaping (Result<(), Error>) -> Void) -> CancelableRequest {
        let request = SignupRequest(email: email, name: name, pass: password)
        return self.execute(api: .signUp , body: request) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func signIn(email: String, password: String, completion: @escaping (Result<(), Error>) -> Void) -> CancelableRequest {
        let request = SigninRequest(email: email, pass: password)
        return self.execute(api: .signIn , body: request) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func signOut(email: String, password: String, completion: @escaping (Result<(), Error>) -> Void) -> CancelableRequest {
        let body: Int? = nil
        return self.execute(api: .signOut , body: body) { (result: Result<String?, Error>) in
            let converted: Result<(), Error> = result.flatMap({ _ in Result.success(()) })
            completion(converted)
        }
    }

    @discardableResult public func getUserInfo(completion: @escaping (Result<UserInfoResponse, Error>) -> Void) -> CancelableRequest {
        let body: Int? = nil
        return self.execute(api: .signOut , body: body) { (result: Result<UserInfoResponse?, Error>) in
            let converted: Result<UserInfoResponse, Error> = result.flatMap({ Result.success($0!) })
            completion(converted)
        }
    }

}
