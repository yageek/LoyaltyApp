//
//  InfosVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import RxSwift

protocol InfosVCDelegate: AnyObject {
    func infosVCDidSignout(_ controller: InfosVC)
}

final class InfosVC: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loyaltyCountLabel: UILabel!

    private let totalCount: Int

    weak var delegate: InfosVCDelegate?

    // MARK: - Init
    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies

    let disposeBag = DisposeBag()

    init(dependencies: Dependencies, totalCount: Int) {
        self.totalCount = totalCount
        self.dependencies = dependencies
        super.init(nibName: "InfosVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dependencies.apiService.getUserInfo()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] value in
                guard let self = self else { return }

                self.emailLabel.text = value.email
                self.nameLabel.text = value.name
                self.loyaltyCountLabel.text = "\(self.totalCount) loyalties total"
            } onFailure: { [weak self] error in
                self?.presentAlertController(message: error.localizedDescription)
            }.disposed(by: self.disposeBag)
    }

    @IBAction func logOutTriggered(_ sender: Any) {

        self.dependencies.apiService.signOut()
            .observe(on: MainScheduler.instance)        
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.infosVCDidSignout(self)
            }.disposed(by: self.disposeBag)
    }
}
