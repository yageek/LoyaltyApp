//
//  CardListCellViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import UIKit
import RxSwift
import RxCocoa
import LoyaltyAPIClient

final class CardListCellViewModel {

    let disposeBag = DisposeBag()

    enum Section: Hashable {
        case main
    }

    enum Cell: Hashable {
        case card(CardResource)
        case loading
    }

    // MARK: - Var

    typealias Dependencies = HasAPIClientService
    private var currentOffset: UInt?
    private var totalCount: Int?

    private var elements: [CardResource] = []

    private var _changes: BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Cell>> = BehaviorRelay(value: NSDiffableDataSourceSnapshot())
    var changes: Observable<NSDiffableDataSourceSnapshot<Section, Cell>> { return _changes.asObservable() }
    let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        loadNextPage()
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
        self.dependencies.apiService.getAllLoyalties(offset: requestOffset*pageSize, limit: pageSize).subscribe(onSuccess: { [weak self] page in
            guard let self = self else { return }


//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [weak self] in
//                    self?.presentAlertController(message: error.localizedDescription)
//                }



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
                self._changes.accept(patch)
        }).disposed(by: self.disposeBag)
    }

    private func resetData() {
        self.elements.removeAll()
        self.currentOffset = nil
        self.totalCount = nil

        let patch = NSDiffableDataSourceSnapshot<Section, Cell>()
        self._changes.accept(patch)

        loadNextPage()

    }
}
