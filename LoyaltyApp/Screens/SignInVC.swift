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
    func signInViewControllerDidFailedToSignIn(_ controller: SignInVC, credential: String, error: Error)
}

final class SignInVC: UIViewController, Bindable {
    // MARK: - iVar | UIKit
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var signInButton: UIButton!

    // MARK: - iVar | Rx
    private let disposeBag = DisposeBag()
    private var viewModel: SignInViewModel?

    // MARK: - iVar | API
    weak var delegate: SignInVCDelegate?

    // MARK: - Init
    typealias Dependencies = HasAPIClientService

    let dependencies: Dependencies
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: "SignInVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = SignInViewModel(dependencies: self.dependencies)
        self.bind(to: viewModel)
    }

    func bind(to viewModel: SignInViewModel) {
        /// Binds Inputs
        self.emailTextField.rx.text.bind(to: viewModel.input.emailInput).disposed(by: self.disposeBag)
        self.passwordTextField.rx.text.bind(to: viewModel.input.passInput).disposed(by: self.disposeBag)
        self.signInButton.rx.controlEvent(.touchUpInside).bind(to: viewModel.input.buttonTriggered).disposed(by: self.disposeBag)

        /// Binds Outputs
        // Loading indicator
        viewModel.output.isActivityIndicatorAnimating.drive(activityIndicator.rx.isAnimating).disposed(by: self.disposeBag)

        // Locking input
        viewModel.output.inputEnabled.drive(passwordTextField.rx.isEnabled).disposed(by: self.disposeBag)
        viewModel.output.inputEnabled.drive(emailTextField.rx.isEnabled).disposed(by: self.disposeBag)
        viewModel.output.inputEnabled.drive(signInButton.rx.isEnabled).disposed(by: self.disposeBag)

        // Sign in result
        viewModel.output.signInResult.subscribe(onNext: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let credentialError):
                self.delegate?.signInViewControllerDidFailedToSignIn(self, credential: credentialError.email, error: credentialError.error)
            case .success(_):
                self.delegate?.signInViewControllerDidSignInWithSuccess(self)
            }
        }).disposed(by: self.disposeBag)
        self.viewModel = viewModel
    }
}



