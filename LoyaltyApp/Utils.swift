//
//  Utils.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 19/02/2021.
//

import UIKit

extension UIViewController {

    func presentAlertController(message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (_) in
            completion?()
        }))
        self.present(alert, animated: true)
    }
}
