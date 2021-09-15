//
//  CardListVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient
import RxSwift

private let CardCellID = "CardCell"
private let LoadingCellID = "LoadingCell"

protocol CardListVCDelegate: AnyObject {
    func listViewControllerDidSignout(_ controller: CardListVC)
    func listViewControllerRequiredAddCard(_ controller: CardListVC)
    func listViewControllerDidSelectUserInfo(_ controller: CardListVC)
}

final class CardListVC: UICollectionViewController, Bindable {

    weak var delegate: CardListVCDelegate?

    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies

    private var viewModel: CardListViewModel?

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5.0, bottom: 5.0, trailing: 5.0)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150.0))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Var
    private var currentOffset: UInt?
    private(set) var totalCount: Int?

    let disposeBag = DisposeBag()
    private var elements: [CardResource] = []
    private var dataSource: UICollectionViewDiffableDataSource<CardListViewModel.Section, CardListViewModel.Cell>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View
        self.collectionView.backgroundColor = .white
        self.collectionView.register(UINib(nibName: "CardCellView", bundle: nil), forCellWithReuseIdentifier: CardCellID)
        self.collectionView.register(UINib(nibName: "LoadingCellView", bundle: nil), forCellWithReuseIdentifier: LoadingCellID)

        // Button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(CardListVC.userInfo))

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CardListVC.addCard))
        // Update

        let dataSource = UICollectionViewDiffableDataSource<CardListViewModel.Section, CardListViewModel.Cell>(collectionView: self.collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
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
        self.dataSource = dataSource

        let viewModel = CardListViewModel(dependencies: self.dependencies)
        self.bind(to: viewModel)
        self.viewModel = viewModel
    }

    // MARK: - Unwind

    func bind(to viewModel: CardListViewModel) {

        // Inputs
        self.collectionView.rx.willDisplayCell.map { $1 }.bind(to: viewModel.input.willDisplayCell).disposed(by: self.disposeBag)

        // Outputs
        viewModel.output.content.drive(onNext: { [weak self] snapshot in
            self?.dataSource?.apply(snapshot)
        }).disposed(by: self.disposeBag)

    }
    // MARK: - Actions
    @objc private func signout() {
        self.dependencies.apiService.signOut().observe(on: MainScheduler.instance).subscribe { [weak self] _ in

            guard let self = self else { return }
            self.delegate?.listViewControllerDidSignout(self)
            
        } onFailure: { error in
            print("Error: \(error)")
        }.disposed(by: self.disposeBag)

    }

    @objc private func addCard() {
        self.delegate?.listViewControllerRequiredAddCard(self)
    }
    @objc private func userInfo() {
        self.delegate?.listViewControllerDidSelectUserInfo(self)
    }
}
