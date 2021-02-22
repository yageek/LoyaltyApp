//
//  SignInVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient

final class SignInVC: UIViewController {

    @IBOutlet private(set) weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var passwordTextField: UITextField!
    @IBOutlet private(set) weak var emailTextField: UITextField!
    @IBOutlet private(set) weak var signInButton: UIButton!


    // MARK: - Init
    init() {
        super.init(nibName: "SignInVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action
    @IBAction func singInTriggered(_ sender: Any) {
        self.trySignIn()

    }
    @IBAction func unwindToSignInFromSignUp(sender: UIStoryboardSegue) {

        if let signIn = sender.source as? SignUpVC {
            self.emailTextField.text = signIn.emailTextField.text
            self.passwordTextField.text = nil
        }
    }

    // MARK: - Send
    func trySignIn() {

        let email = emailTextField.text ?? ""
        let pass = passwordTextField.text ?? ""

        self.activityIndicator.startAnimating()
        LoyaltyAPIClient.shared.signIn(email: email, password: pass) { [weak self] (result) in

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in

                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                switch result {
                case .failure(let error):
                    print("SignUp: \(error)")
                    self.performSegue(withIdentifier: "showSignUp", sender: self)
                case .success(_):
                    self.performSegue(withIdentifier: "showCardList", sender: self)
                }
            }
        }
    }

    @IBAction func unwindFromUserInfoToSignIn(segue: UIStoryboardSegue ) {


    }
}

