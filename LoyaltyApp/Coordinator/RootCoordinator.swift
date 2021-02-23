//
//  RootCoordinator.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import UIKit

final class RootCoordinator: BaseCoordinator {

    private var window: UIWindow

    private lazy var rootNavigationController: UINavigationController = {
        let signIn = SignInVC()
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
}

// MARK: - SignInVCDelegate
extension RootCoordinator: SignInVCDelegate {
    func signInViewControllerDidSignInWithSuccess(_ controller: SignInVC) {

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
        // TODO: Move to list
    }

    func signUpViewController(_ controller: SignUpVC, didFailedToSignUpWithError error: Error) {
        controller.presentAlertController(message: error.localizedDescription)
    }
}
