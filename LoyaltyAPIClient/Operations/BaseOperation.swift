//
//  BaseOperation.swift
//  LoyaltyAPIClient
//
//  Created by eidd5180 on 18/02/2021.
//

import Foundation
class BaseOperation: Operation {

    // MARK: - Helper Begin
    var _isFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }

        get {
            return _isFinished
        }
    }

    var _isExecuting: Bool = false

    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }

        get {
            return _isExecuting
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

/// A protocol representing something that can be cancelled
public protocol CancellableRequest {
    /// Cancel the current request
    func cancel()
}

/// :nodoc:
extension Operation: CancellableRequest { }

