//
//  SignInVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient
import RxSwift
import RxCocoa

protocol SignInVCDelegate: AnyObject {
    func signInViewControllerDidSignInWithSuccess(_ controller: SignInVC)
    func signInViewControllerDidFailedToSignIn(_ controller: SignInVC, credential:SignInVC.Credential, error: Error)
}

final class SignInVC: UIViewController {

    typealias Dependencies = HasAPIClientService

    struct Credential {
        let email: String
        let password: String
    }

    // MARK: - iVar | iVar
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var signInButton: UIButton!

    private let dependencies: Dependencies
    private let disposeBag = DisposeBag()

    weak var delegate: SignInVCDelegate?

    // MARK: - Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: "SignInVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action
    @IBAction func singInTriggered(_ sender: Any) {
        self.trySignIn()
    }

    // MARK: - Send
    func trySignIn() {

        let email = emailTextField.text ?? ""
        let pass = passwordTextField.text ?? ""

        self.activityIndicator.startAnimating()

        self.dependencies.apiService.rx_signIn(email: email, password: pass)
            .delaySubscription(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }

                self.delegate?.signInViewControllerDidSignInWithSuccess(self)
            }, onFailure: { [weak self] (error) in
                guard let self = self else { return }
                let credential = Credential(email: email, password: pass)
                self.delegate?.signInViewControllerDidFailedToSignIn(self, credential: credential, error: error)

            }).disposed(by: self.disposeBag)

// Combine version:
//        self.dependencies.apiService.signIn(email: email, password: pass)
//            .delay(for: .milliseconds(800), scheduler: DispatchQueue.main)
//            .sink { [weak self] (completion) in
//                guard let self = self else { return }
//                let credential = Credential(email: email, password: pass)
//                if case .failure(let error) = completion {
//                    self.delegate?.signInViewControllerDidFailedToSignIn(self, credential: credential, error: error)
//                }
//
//        } receiveValue: { [weak self] error in
//            guard let self = self else { return }
//
//            self.delegate?.signInViewControllerDidSignInWithSuccess(self)
//
//        }.store(in: &self.disposeBag)
    }
}


