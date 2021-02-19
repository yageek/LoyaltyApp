//
//  InfosVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient

final class InfosVC: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loyaltyCountLabel: UILabel!

    var totalCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        LoyaltyAPIClient.shared.getUserInfo { [weak self] (result) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.presentAlertController(message: error.localizedDescription) { [weak self] in
                        self?.performSegue(withIdentifier: "unwindToCardListFromInfo", sender: self)
                    }
                case .success(let value):
                    self.emailLabel.text = value.email
                    self.nameLabel.text = value.name
                    self.loyaltyCountLabel.text = "\(self.totalCount) loyalties total"
                }
            }
        }

    }
}
