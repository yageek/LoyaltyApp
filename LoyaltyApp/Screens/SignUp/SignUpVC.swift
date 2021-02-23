//
//  SignUpVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import RxSwift

protocol SignUpVCDelegate: AnyObject {
    func signUpViewControllerDidLoginWithSuccess(_ controller: SignUpVC)
    func signUpViewController(_ controller: SignUpVC, didFailedToSignUpWithError error: Error)
}
final class SignUpVC: UIViewController {

    typealias Dependencies = HasAPIClientService

    // MARK: - iVar | UIKit
    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var signUpButton: UIButton!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var nameTextField: UITextField!

    // MARK: - iVar | DI
    private let dependencies: Dependencies
    // MARK: - iVar | Rx
    private let disposeBag = DisposeBag()
    private var viewModel: SignUpViewModel?

    weak var delegate: SignUpVCDelegate?

    // MARK: - Init
    init(dependencies: Dependencies, email: String?) {
        self.dependencies = dependencies
        super.init(nibName: "SignUpVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = SignUpViewModel(dependencies: DI())

        // Binds Inputs
        emailTextField.rx.text.bind(to: viewModel.emailInput).disposed(by: self.disposeBag)
        passwordTextField.rx.text.bind(to: viewModel.passInput).disposed(by: self.disposeBag)
        nameTextField.rx.text.bind(to: viewModel.nameInput).disposed(by: self.disposeBag)
        signUpButton.rx.controlEvent(.touchUpInside).map { _ in () }.bind(to: viewModel.buttonTriggered).disposed(by: self.disposeBag)

        // Binds Outputs
        /// Binds Outputs
        // Loading indicator
        viewModel.isActivityIndicatorAnimating.drive(activityIndicator.rx.isAnimating).disposed(by: self.disposeBag)

        // Locking input
        viewModel.inputEnabled.drive(passwordTextField.rx.isEnabled).disposed(by: self.disposeBag)
        viewModel.inputEnabled.drive(emailTextField.rx.isEnabled).disposed(by: self.disposeBag)
        viewModel.inputEnabled.drive(nameTextField.rx.isEnabled).disposed(by: self.disposeBag)
        viewModel.inputEnabled.drive(signUpButton.rx.isEnabled).disposed(by: self.disposeBag)

        // Sign in result
        viewModel.signInResult.emit(onNext: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let credentialError):
                self.delegate?.signUpViewController(self, didFailedToSignUpWithError: credentialError)
            case .success(_):
                self.delegate?.signUpViewControllerDidLoginWithSuccess(self)
            }
        }).disposed(by: self.disposeBag)
        self.viewModel = viewModel


    }
}
