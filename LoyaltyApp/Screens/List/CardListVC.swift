//
//  CardListVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 18/02/2021.
//

import UIKit
import LoyaltyAPIClient

private let CardCellID = "CardCell"
private let LoadingCellID = "LoadingCell"

final class CardListVC: UICollectionViewController {

    enum Section: Hashable {
        case main
    }

    enum Cell: Hashable {
        case card(CardResource)
        case loading
    }

    // MARK: - Var
    private var currentOffset: UInt?
    private var totalCount: Int?

    private var elements: [CardResource] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Cell>?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        LoyaltyAPIClient.shared.getAllLoyalties(offset: requestOffset*pageSize, limit: pageSize) { (result) in
            switch result {
            case .failure(let error):

                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in
                    self?.presentAlertController(message: error.localizedDescription)
                }

            case .success(let page):

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
            }
        }
    }

    // MARK: - Unwind
    @IBAction func unwindFromUserInfo(segue: UIStoryboardSegue) { }
    @IBAction func unwindFromAddEditCancel(segue: UIStoryboardSegue) { }
    @IBAction func unwindFromAddEdit(segue: UIStoryboardSegue) {
        self.resetData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infosVC = segue.destination as? InfosVC {
            infosVC.totalCount = self.totalCount ?? -1
        }
    }

    private func resetData() {
        self.elements.removeAll()
        self.currentOffset = nil
        self.totalCount = nil

        var patch = NSDiffableDataSourceSnapshot<Section, Cell>()
        self.dataSource?.apply(patch)

        loadNextPage()

    }
}
