//
//  ListCoordinator.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import Foundation
import UIKit

protocol ListCoordinatorDelegate: AnyObject {
    func listCoordinatorDidTerminate(_ coordinator: ListCoordinator)
}

final class ListCoordinator: BaseCoordinator {

    let navigationController: UINavigationController

    weak var delegate: ListCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    override func start() {

        let list = CardListVC()
        self.navigationController.pushViewController(list, animated: true)
    }
}
