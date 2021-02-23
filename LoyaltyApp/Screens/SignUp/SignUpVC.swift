//
//  SignUpVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient

final class SignUpVC: UIViewController {

    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var signUpButton: UIButton!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var nameTextField: UITextField!


    // MARK: - Init
    init(email: String?) {
        super.init(nibName: "SignUpVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func trySignup() {


        let email = emailTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        let name = nameTextField.text ?? ""

        guard !email.isEmpty && !pass.isEmpty && !name.isEmpty else {
            self.presentAlertController(message: "Invalid inputs")
            return
        }

        self.activityIndicator.startAnimating()
        LoyaltyAPIClient.shared.signUp(email: email, password: pass, name: name) { [weak self] (result) in

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in

                guard let self = self else { return }
                self.activityIndicator.stopAnimating()

                switch result {
                case .failure(let error):
                    self.presentAlertController(message: error.localizedDescription)
                case .success(_):
                    self.performSegue(withIdentifier: "unwindToSignIn", sender: self)
                }
            }
        }
    }
}
