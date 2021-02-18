//
//  RequestOperation.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation
final class RequestOperation<E: Endpoint, Body: Encodable, ResponseBody: Decodable>: BaseOperation {

    // MARK: - Var
    typealias Completion = (Result<ResponseBody?, Error>) -> Void
    private let session: URLSession
    private let endpoint: E
    private let body: Body?
    private let responseCompletion: Completion
    private var dataTask: URLSessionTask?

    // MARK: - Init
    init(session: URLSession = .shared, endpoint: E, body: Body?, completion: @escaping Completion) {
        self.session = session
        self.endpoint = endpoint
        self.body = body
        self.responseCompletion = completion

        super.init()
        self.name = "net.yageek.RequestOperation\(type(of: self))"
    }


    override var isAsynchronous: Bool { return true }
    override func start() {

        self.isExecuting = true
        self.isFinished = false

        // We first need to encode the request

        do {
            let request = try RequestOperation.request(from: self.endpoint, body: self.body)

            let task = self.session.dataTask(with: request) { [weak self] (data, response, error) in
                self?.dataResponse(data: data, response: response as? HTTPURLResponse, error: error)
            }
            self.dataTask = task
            task.resume()

        } catch let error {
            self.finish(withError: error)
        }
    }

    private func dataResponse(data: Data?, response: HTTPURLResponse?, error: Error?) {

        if let error = error {
            self.finish(withError: error)
        } else if let response = response {

            
        }
    }
    // MARK: - Cancel

    override func cancel() {

        self.dataTask?.cancel()
        super.cancel()
    }

    // MARK: - Finish
    func finish(withSuccess success: ResponseBody?) {
        self.responseCompletion(.success(success))
        self.finish()
    }

    func finish(withError error: Error) {
        self.responseCompletion(.failure(error))
        self.finish()
    }

    // MARK: - Encoding - Decoding
    static func urlPath(from endpoint: E) -> URL {

        var parameters:  [String: Any] = [:]
        for (key, value) in endpoint.params {
            parameters[key] = value
        }

        let pathURL = endpoint.baseHost.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.sorted(by: { $0.key > $1.key }).map { value in
            return URLQueryItem(name: value.key, value: "\(value.value)")
        }

        guard let url = components?.url else { fatalError("Wrong API specification")}
        return url
    }

    static func request(from endpoint: E, body: Body?) throws -> URLRequest {

        let url = RequestOperation.urlPath(from: endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.httpMethod

        // Body
        if let body = body {
            let data = try JSONEncoder().encode(body)
            request.httpBody = data
        }
        return request

    }

}
