//
//  Utils.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 19/02/2021.
//

import UIKit

extension UIViewController {

    func presentAlertController(message: String?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        self.present(alert, animated: true)
    }
}
