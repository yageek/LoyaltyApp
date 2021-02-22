//
//  AddEditVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient

final class AddEditVC: UIViewController {
    @IBOutlet private(set) weak var addEditButton: UIButton!
    @IBOutlet private(set) weak var nameTextField: UITextField!

    @IBOutlet private(set) weak var codeTextField: UITextField!
    @IBOutlet private(set) weak var colorTextField: UITextField!
    var currentModel: CardResource?

    // MARK: - Init
    init() {
        super.init(nibName: "AddEditVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentModel = self.currentModel {
            self.addEditButton.setTitle("Edit", for: .normal)

            self.nameTextField.text = currentModel.name
            self.codeTextField.text = currentModel.code
            self.colorTextField.text = currentModel.color

        } else {
            self.addEditButton.setTitle("Add", for: .normal)
        }
    }

    @IBAction func addEditTriggered(_ sender: Any) {

        self.addEdit()

    }

    private func addEdit() {

        let name = self.nameTextField.text ?? ""
        let code = self.codeTextField.text ?? ""
        let color = self.colorTextField.text ?? ""

        if let currentModel = self.currentModel {

            LoyaltyAPIClient.shared.updateLoyalty(id: currentModel.id, name: currentModel.name, code: code, color: color) { (result) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                    switch result {
                    case .success(_):
                        self.performSegue(withIdentifier: "unwindFromAddEdit", sender: self)
                    case .failure(let error):
                        self.presentAlertController(message: error.localizedDescription)
                    }

                }
            }
        } else {

            LoyaltyAPIClient.shared.addLoyalty(name: name, code: code, color: color) { (result) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                    switch result {
                    case .success(_):
                        self.performSegue(withIdentifier: "unwindFromAddEdit", sender: self)
                    case .failure(let error):
                        self.presentAlertController(message: error.localizedDescription)
                    }
                }
            }
        }
    }
}
