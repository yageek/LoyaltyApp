//
//  RootCoordinator.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import UIKit
import LoyaltyAPIClient
final class RootCoordinator: BaseCoordinator {

    private var window: UIWindow

    private lazy var rootNavigationController: UINavigationController = {
        let signIn = SignInVC(dependencies: AppDi.shared)
        signIn.delegate = self
        let root = UINavigationController(rootViewController: signIn)
        return root
    }()

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    override func start() {
        self.window.rootViewController = self.rootNavigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Helper

    private func pushList() {
        let list = CardListVC(dependencies: AppDi.shared)
        list.delegate = self
        self.rootNavigationController.pushViewController(list, animated: true)
    }
}

// MARK: - SignInVCDelegate
extension RootCoordinator: SignInVCDelegate {
    func signInViewControllerDidSignInWithSuccess(_ controller: SignInVC) {
        self.pushList()
    }

    func signInViewControllerDidFailedToSignIn(_ controller: SignInVC, credential: String, error: Error) {
        let signUp = SignUpVC(email: credential)
        signUp.delegate = self
        controller.present(signUp, animated: true)
    }
}


// MARK: - SignUpVCDelegate
extension RootCoordinator: SignUpVCDelegate {
    func signUpViewControllerDidLoginWithSuccess(_ controller: SignUpVC) {
        controller.dismiss(animated: true)
    }

    func signUpViewController(_ controller: SignUpVC, didFailedToSignUpWithError error: Error) {
        controller.presentAlertController(message: error.localizedDescription)
    }
}


// MARK: - CardListVCDelegate
extension  RootCoordinator: CardListVCDelegate {

    func listViewControllerDidSignout(_ controller: CardListVC) {
        self.rootNavigationController.popViewController(animated: true)
    }

    func listViewControllerRequiredAddCard(_ controller: CardListVC) {
        let add = AddEditVC(dependencies: AppDi.shared, currentModel: nil)
        add.delegate = self
        controller.present(add, animated: true)
    }
    func listViewControllerDidSelectUserInfo(_ controller: CardListVC) {
        let controller = InfosVC(dependencies: AppDi.shared, totalCount: controller.totalCount ?? 0)
        controller.delegate = self
        self.rootNavigationController.pushViewController(controller, animated: true)
    }
}

// MARK: - InfosVCDelegate
extension RootCoordinator: InfosVCDelegate {
    func infosVCDidSignout(_ controller: InfosVC) {
        self.rootNavigationController.popToRootViewController(animated: true)
    }
}
// MARK: - AddEditVCDelegate
extension RootCoordinator: AddEditVCDelegate {
    func addEditVC(_ controller: AddEditVC, failedToEditCard error: Error) {
        controller.presentAlertController(message: error.localizedDescription)
    }

    func addEditVC(_ controller: AddEditVC, didAddorUpdateCard: CardResource) {
        controller.dismiss(animated: true)
        if let list = self.rootNavigationController.topViewController as? CardListVC {            

        }
    }
    
}
