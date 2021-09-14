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

final class CardListVC: UICollectionViewController {

    enum Section: Hashable {
        case main
    }

    enum Cell: Hashable {
        case card(CardResource)
        case loading
    }

    weak var delegate: CardListVCDelegate?

    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies

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
    private var dataSource: UICollectionViewDiffableDataSource<Section, Cell>?

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

        let dataSource = UICollectionViewDiffableDataSource<Section, Cell>(collectionView: self.collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
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
        self.loadNextPage()
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let viewLayer = cell.contentView.layer
        viewLayer.borderColor = UIColor.red.cgColor
        viewLayer.borderWidth = 2.0
        viewLayer.cornerRadius = 20.0

        guard let dataSource = self.dataSource else { return }
        if case .loading = dataSource.itemIdentifier(for: indexPath) {
            self.loadNextPage()
        }
    }
    // MARK: - Loading

    private func loadNextPage() {

        if let totalCount = self.totalCount, self.elements.count >= totalCount { return }

        let requestOffset: UInt
        if let current = self.currentOffset {
            requestOffset = current + 1
        } else {
            requestOffset = 0
        }

        let pageSize: UInt = 10

        self.dependencies.apiService.getAllLoyalties(offset: requestOffset*pageSize, limit: pageSize).subscribe { [weak self] page in
            guard let self = self else { return }
            if self.totalCount == nil {
                self.totalCount = page.count
            }
            // Memorize before

            var newContents = self.elements
            newContents.append(contentsOf: page.cards)

            let contentSize = newContents.count

            var patch = NSDiffableDataSourceSnapshot<Section, Cell>()
            let cells = newContents.map { Cell.card($0) }
            patch.appendSections([.main])
            patch.appendItems(cells)

            if contentSize < page.count {
                patch.appendItems([.loading])
            }

            self.currentOffset = requestOffset
            self.elements = newContents

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in
                self?.dataSource?.apply(patch)
            }
        } onFailure: { [weak self] error in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in
                self?.presentAlertController(message: error.localizedDescription)
            }
        }.disposed(by: self.disposeBag)
    }

    // MARK: - Unwind

    func resetData() {
        self.elements.removeAll()
        self.currentOffset = nil
        self.totalCount = nil

        let patch = NSDiffableDataSourceSnapshot<Section, Cell>()
        self.dataSource?.apply(patch)

        loadNextPage()
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
