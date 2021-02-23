//
//  CardListVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient
import RxCocoa
import RxSwift

private let CardCellID = "CardCell"
private let LoadingCellID = "LoadingCell"

protocol CardListVCDelegate: AnyObject {

}

final class CardListVC: UICollectionViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: CardListCellViewModel?

    init() {
        super.init(nibName: "CardListVC", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        self.collectionView.register(UINib(nibName: "CardCellView", bundle: nil), forCellWithReuseIdentifier: CardCellID)
        self.collectionView.register(UINib(nibName: "LoadingCellView", bundle: nil), forCellWithReuseIdentifier: LoadingCellID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bindings
        let viewModel = CardListCellViewModel(dependencies: DI())
        let dataSource = UICollectionViewDiffableDataSource<CardListCellViewModel.Section, CardListCellViewModel.Cell>(collectionView: self.collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            switch  element {
            case .card(let item):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCellID, for: indexPath) as! CardCellView
                cell.titleLabel.text = item.name
                cell.codeLabel.text = item.code
                return cell
            case .loading:
                return collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCellID, for: indexPath)
            }
        }
        self.collectionView.dataSource = dataSource

        viewModel.changes.subscribe(onNext: { (patch) in
            dataSource.apply(patch)
        }).disposed(by: self.disposeBag)
        self.viewModel = viewModel
    }
}
