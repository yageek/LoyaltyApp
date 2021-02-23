//
//  Coordinator.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import Foundation

protocol Coordinator: AnyObject {
    func start()
    func addChild(_ child: Coordinator)
    func removeChild(_ child: Coordinator)
}

class BaseCoordinator: Coordinator {
    private var childs: [Coordinator] = []

    func addChild(_ child: Coordinator) {
        self.childs.append(child)
    }

    func removeChild(_ child: Coordinator) {
        if let index = childs.lastIndex(where: { $0 === child }) {
            self.childs.remove(at: index)
        }
    }

    func start() {
        fatalError("Should be overridden")
    }
}
