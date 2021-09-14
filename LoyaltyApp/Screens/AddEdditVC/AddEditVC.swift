//
//  AddEditVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient
import RxSwift
import RxCocoa

protocol AddEditVCDelegate: AnyObject {
    func addEditVC(_ controller: AddEditVC, didAddorUpdateCard: CardResource)
    func addEditVC(_ controller: AddEditVC, failedToEditCard: Error)
}

final class AddEditVC: UIViewController {
    @IBOutlet private(set) weak var addEditButton: UIButton!
    @IBOutlet private(set) weak var nameTextField: UITextField!

    @IBOutlet private(set) weak var codeTextField: UITextField!
    @IBOutlet private(set) weak var colorTextField: UITextField!
    private var currentModel: CardResource?

    private let disposeBag = DisposeBag()

    // MARK: - Init
    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies
    weak var delegate: AddEditVCDelegate?
    init(dependencies: Dependencies, currentModel: CardResource?) {
        self.dependencies = dependencies
        self.currentModel = currentModel
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
            self.dependencies.apiService.updateLoyalty(id: currentModel.id, name: currentModel.name, code: code, color: code)
                .observe(on: MainScheduler.instance)
                .subscribe { [weak self] ressource in
                    guard let self = self else { return }
                    self.delegate?.addEditVC(self, didAddorUpdateCard: ressource)
                } onFailure: { [weak self] error in
                    guard let self = self else { return }
                    self.delegate?.addEditVC(self, failedToEditCard: error)
                }.disposed(by: self.disposeBag)

        } else {

            self.dependencies.apiService.addLoyalty(name: name, code: code, color: color)
                .observe(on: MainScheduler.instance)
                .subscribe { [weak self] ressource in
                    guard let self = self else { return }
                    self.delegate?.addEditVC(self, didAddorUpdateCard: ressource)
                } onFailure: { [weak self] error in
                    guard let self = self else { return }
                    self.delegate?.addEditVC(self, failedToEditCard: error)
                }.disposed(by: self.disposeBag)
        }
    }
}
